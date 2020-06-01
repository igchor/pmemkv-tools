benchmarks=(fillseq fillrandom readseq readrandom)

for engine in stree csmap
do
    ./run_bench_engine.sh $engine 1 /mnt/pmem/pmemkv "${benchmarks[@]}"
done