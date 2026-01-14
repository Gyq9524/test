ps -ef |grep FileCreater-1.0-SNAPSHOT.jar |grep -v grep|awk '{print $2}'|xargs kill -9
java -Dfile.encoding=utf-8 -jar FileCreater-1.0-SNAPSHOT.jar  &


