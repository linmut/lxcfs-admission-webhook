#! /bin/bash
PATH=$PATH:/bin
LXCFS="/var/lib/lxc/lxcfs"
LXCFS_ROOT_PATH="/var/lib/lxc"

rm -rf /var/lib/lxc/lxcfs
#nohup  /usr/local/bin/lxcfs -s -f -o allow_other /var/lib/lxc/lxcfs &
echo "nohup  /usr/local/bin/lxcfs  /var/lib/lxc/lxcfs &"
nohup  /usr/local/bin/lxcfs  /var/lib/lxc/lxcfs &

containers=$(docker ps -q)
for container in $containers;do
      mountpoint=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/lxc" }}{{ .Source }}{{ end }}{{ end }}' $container)
      if [ "$mountpoint" = "$LXCFS_ROOT_PATH" ];then
              echo "remount $container"
              PID=$(docker inspect --format '{{.State.Pid}}' $container)
              # mount /proc
              for file in meminfo cpuinfo stat diskstats swaps uptime;do
                      echo nsenter --target $PID --mount --  mount --bind "$LXCFS/proc/$file" "/proc/$file"
                      nsenter --target $PID --mount --  mount --bind "$LXCFS/proc/$file" "/proc/$file"
              done
      fi
done

