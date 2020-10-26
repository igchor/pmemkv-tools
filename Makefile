.ONESHELL:

install_deps:
	rm -rf deps
	mkdir deps
	cd deps
	git clone https://github.com/${USER}/libpmemobj-cpp
	cd libpmemobj-cpp
	git checkout ${BRANCH}
	mkdir build
	cd build
	cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TESTS=0 -DBUILD_EXAMPLES=0 -DBUILD_BENCHMARKS=0
	make install
	cd ../..
	git clone https://github.com/${USER}/pmemkv
	cd pmemkv
	git checkout ${BRANCH}
	mkdir build
	cd build
	PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${PREFIX}/lib/pkgconfig:${PREFIX}/lib64/pkgconfig cmake .. -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TESTS=0 -DBUILD_EXAMPLES=0 -DCXX_STANDARD=14 -DENGINE_RADIX=1 -DENGINE_STREE=1 -DENGINE_CSMAP=1
	make install
	cd ../../..

compile_deps: install_deps
	LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${PMDK_PREFIX}/lib:${PMDK_PREFIX}/lib64 g++ ./bench/db_bench.cc ./bench/port/port_posix.cc ./bench/util/env.cc ./bench/util/env_posix.cc ./bench/util/histogram.cc ./bench/util/logging.cc ./bench/util/status.cc ./bench/util/testutil.cc -o pmemkv_bench -I./bench/include -I./bench -I./bench/util -I${PREFIX}/include -L${PREFIX}/lib -L${PREFIX}/lib64 -L${PMDK_PREFIX}/lib64 -L${PMDK_PREFIX}/lib -I${PMDK_PREFIX}/include -O2 -std=c++11 -DOS_LINUX -fno-builtin-memcmp -march=native -DNDEBUG -ldl -lpthread -lpmemkv

reset:
	rm -rf /dev/shm/pmemkv /tmp/pmemkv

clean: reset
	rm -rf pmemkv_bench ./c/*.bin ./cpp/*.bin ./java/*.class

bench: reset
	g++ ./bench/db_bench.cc ./bench/port/port_posix.cc ./bench/util/env.cc ./bench/util/env_posix.cc ./bench/util/histogram.cc ./bench/util/logging.cc ./bench/util/status.cc ./bench/util/testutil.cc -o pmemkv_bench -I./bench/include -I./bench -I./bench/util -O2 -std=c++11 -DOS_LINUX -fno-builtin-memcmp -march=native -DNDEBUG -ldl -lpthread -lpmemkv

run_bench: bench
	PMEM_IS_PMEM_FORCE=1 ./pmemkv_bench --db=/dev/shm/pmemkv --db_size_in_gb=1 --histogram=1

baseline_c: reset
	cd c
	echo 'Build and run baseline.c'
	cd .. && $(MAKE) reset

baseline_cpp: reset
	cd cpp
	g++ baseline.cc -o baseline.bin -O2 -std=c++11 -lpmemkv
	PMEM_IS_PMEM_FORCE=1 ./baseline.bin
	cd .. && $(MAKE) reset

baseline_java: reset
	cd java
	javac -cp ../../pmemkv-java/target/*.jar Baseline.java
	PMEM_IS_PMEM_FORCE=1 java -Xms1G -cp .:`find ../../pmemkv-java/target -name *.jar` -Djava.library.path=/usr/local/lib Baseline
	cd .. && $(MAKE) reset

baseline_nodejs: reset
	cd nodejs
	PMEM_IS_PMEM_FORCE=1 node baseline.js
	cd .. && $(MAKE) reset

baseline_ruby: reset
	cd ruby
	PMEM_IS_PMEM_FORCE=1 ruby baseline.rb
	cd .. && $(MAKE) reset

baseline_python: reset
	cd python
	PMEM_IS_PMEM_FORCE=1 python3 baseline.py
	cd .. && $(MAKE) reset

iteration_cpp: reset
	cd cpp
	g++ iteration.cc -o iteration.bin -O2 -std=c++11 -lpmemkv
	PMEM_IS_PMEM_FORCE=1 ./iteration.bin
	cd .. && $(MAKE) reset

iteration_java: reset
	cd java
	javac -cp ../../pmemkv-java/target/*.jar Iteration.java
	PMEM_IS_PMEM_FORCE=1 java -Xms1G -cp .:`find ../../pmemkv-java/target -name *.jar` -Djava.library.path=/usr/local/lib Iteration
	cd .. && $(MAKE) reset

iteration_python: reset
	cd python
	PMEM_IS_PMEM_FORCE=1 python3 iteration.py
	cd .. && $(MAKE) reset

storage_efficiency: reset
	cd ruby
	PMEM_IS_PMEM_FORCE=1 ruby storage_efficiency.rb
	cd .. && $(MAKE) reset
