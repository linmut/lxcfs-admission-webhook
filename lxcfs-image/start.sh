#!/bin/bash

RETRY_COUNT=$1
if [[ "${RETRY_COUNT}x" == "x" ]];then
  RETRY_COUNT=5
fi

LXCFS_ROOT=$2
if [[ "${LXCFS_ROOT}x" == "x" ]];then
  LXCFS_ROOT=/var/lib/lxc
fi

DEBUG=$3

function exit_child()
{
        echo "exiting..."
        kill -15 -$BASHPID
}
trap exit_child INT TERM

# umount lxcfs on host
nsenter -t 1 -m fusermount -u /var/lib/lxcfs 2> /dev/null || true
nsenter -t 1 -m fusermount -u ${LXCFS_ROOT}/lxcfs 2> /dev/null || true

# start lxcfs
/usr/local/bin/lxcfs $DEBUG --enable-cfs --enable-pidfd ${LXCFS_ROOT}/lxcfs &

i=0
until ls ${LXCFS_ROOT}/lxcfs/proc/meminfo &> /dev/null;do echo "waiting lxcfs to start..." && sleep 0.5 && i=$((i+1)) && if [[ $i -ge $RETRY_COUNT ]];then exit 1;fi;done

# remount containers lxcfs controllers if needed
REMOUNT_SCRIPT='
echo
echo "remount start"

CONTAINERD_SOCK="<none>"
CONTAINERD_SOCKS=( "/run/containerd/containerd.sock" "/run/docker/containerd/docker-containerd.sock")
for cs in ${CONTAINERD_SOCKS[@]};do
  if [[ -S $cs ]];then
    CONTAINERD_SOCK=$cs
    break;
  fi
done
if [[ $CONTAINERD_SOCK == "<none>" ]];then
  echo "no containerd socket found"
  exit 1
fi

CTR_EXE="<none>"
CTR_EXES=( "/usr/local/bin/ctr" "/usr/bin/ctr" "/usr/bin/docker-container-ctr")
for cmd in ${CTR_EXES[@]};do
  if [[ -e $cmd ]];then
    CTR_EXE=$cmd
    break;
  fi
done
if [[ $CTR_EXE == "<none>" ]];then
  echo "no ctr exe found"
  exit 1
fi

CTR_CMD="${CTR_EXE} -a ${CONTAINERD_SOCK}"

CTR_NS="<none>"
CTR_NSS=( "k8s.io" "moby")
for ns in ${CTR_NSS[@]};do
  if [[ $($CTR_CMD -n $ns t ls | wc -l) -gt 1 ]];then
    CTR_NS=$ns
    break;
  fi
done
if [[ $CTR_NS == "<none>" ]];then
  echo "no containerd namespace found or no running containers"
  exit 1
fi

CTR_CMD="${CTR_EXE} -a ${CONTAINERD_SOCK} -n $CTR_NS"

PIDS=$($CTR_CMD t ls | tail -n +2 |tr -s " " | cut -d " " -f 2)
for pid in $PIDS;do
  if grep " /var/lib/lxc " /proc/$pid/mountinfo &> /dev/null; then
    echo
    for file in cpuinfo diskstats loadavg meminfo stat swaps uptime;do
      echo "remount lxcfs $file for $pid"
      nsenter -t $pid -m mount --bind "/var/lib/lxc/lxcfs/proc/$file" "/proc/$file"
    done
    nsenter -t $pid -m mount -B "/var/lib/lxc/lxcfs/sys/devices/system/cpu/online" "/sys/devices/system/cpu/online"
  fi
done

echo
echo "remount done"
'
nsenter -t 1 -m bash -c "$REMOUNT_SCRIPT"

until ! ps aux | grep [/]usr/local/bin/lxcfs &> /dev/null;do sleep 2;done

echo "lxcfs process quited"
nsenter -t 1 -m fusermount -u ${LXCFS_ROOT}/lxcfs 2> /dev/null || true