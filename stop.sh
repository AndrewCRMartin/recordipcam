for pid in `ps auxwww | grep recordipcam | grep -v grep | awk '{print $2}'`
do
    kill -9 $pid;
done
