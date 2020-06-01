engine=$1
shift
threads=$1
shift
db=$1
shift
benchmarks=$@

echo "engine=$engine, threads=$threads, key size=16, value_size=100"
echo ""

echo "benchmark,bandwidth [MB/s],p50 [microsecond/op],p75 [microsecond/op],p99 [microsecond/op],p99.9 [microsecond/op],p99.99 [microsecond/op]"

for benchmark in $benchmarks
do
	result=$(./pmemkv_bench --engine=$engine --db_size_in_gb=100 --db=$db --num=5000000 --benchmarks=$benchmark --histogram=1)
    bandwidth=$(echo "$result" | grep "MB/s" | sed 's/;/,/g' | sed 's/:/,/g' | sed 's/MB\/s/,/g' | cut -d "," -f 3)
    percentiles=$(echo "$result" | grep "Percentiles" | cut -d " " -f 3,5,7,9,11 --output-delimiter=",")
    echo "$benchmark,$bandwidth,$percentiles"
done

echo ""
echo ""
