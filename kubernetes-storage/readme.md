# Использование LVM и iSCSI для создания хранилища

Если хочется использовать storage provisioner то лучше воспользоваться [этим](https://github.com/kubernetes-incubator/external-storage/tree/master/iscsi/targetd/kubernetes).

## Настройка LVM
Создаем Phisical Volume
```
# pvcreate /dev/sdb1
```
Проверяем
```
# pvscan

 PV /dev/sdb1                      lvm2 [<50.00 GiB]
  Total: 1 [<50.00 GiB] / in use: 0 [0   ] / in no VG: 1 [<50.00 GiB]
```

Создаем Virtual Group
```
# vgcreate /dev/sdb1
```

Проверяем
```
# vgdisplay

  --- Volume group ---
  VG Name               vol1
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <50.00 GiB
  PE Size               4.00 MiB
  Total PE              12799
  Alloc PE / Size       0 / 0   
  Free  PE / Size       12799 / <50.00 GiB
  VG UUID               8dz0bq-ojFh-mHU7-CnE4-DGQz-6xxf-BEczFw
```

Создаем логический том (Logical Volume)
```
# lvcreate -n lvol1 -L20G vol1
  Logical volume "lvol1" created.
```

Проверяем
```
# lvdisplay
  --- Logical volume ---
  LV Path                /dev/vol1/lvol1
  LV Name                lvol1
  VG Name                vol1
  LV UUID                Q8cNf4-7abT-wy6q-vnRv-u7jz-fqCh-LxV8DT
  LV Write Access        read/write
  LV Creation host, time instance-main, 2019-09-09 15:44:51 +0000
  LV Status              available
  # open                 0
  LV Size                20.00 GiB
  Current LE             5120
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0
```

В логическом томе создаем файлофую систему EXT4   
```
# mkfs.ext4 /dev/vol1/lvol1
mke2fs 1.44.1 (24-Mar-2018)
Discarding device blocks: done                            
Creating filesystem with 5242880 4k blocks and 1310720 inodes
Filesystem UUID: fe875e7b-f17e-4f8d-9b2e-477edffb82ee
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000
Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done   
```

## Далее настраиваем iSCSI
```
# targetcli
/backstores/block create storage01 /dev/vol1/lvol1
Created block storage object storage01 using /dev/vol1/lvol1.

/iscsi create
Created target iqn.2003-01.org.linux-iscsi.instance-main.x8664:sn.1efa8fbe91d8.
Created TPG 1.
Global pref auto_add_default_portal=true
Created default portal listening on all IPs (0.0.0.0), port 3260.
```

Далее отключаем авторизацию
```
cd iscsi/iqn.2003-01.org.linux-iscsi.instance-main.x8664:sn.1efa8fbe91d8/tpg1
set parameter AuthMethod=None
Parameter AuthMethod is now 'None'.

 set attribute authentication=0
Parameter authentication is now '0'.


luns/ create /backstores/block/storage01
Created LUN 0.
```

На другой машине проверяем что все хорошо
```
#iscsiadm -m discovery -t st -p 10.128.0.6
10.128.0.6:3260,1 iqn.2003-01.org.linux-iscsi.instance-main.x8664:sn.1efa8fbe91d8
```

Теперь можно использовать iscsi storage в поде. [Пример PV](https://github.com/kubernetes/examples/blob/master/volumes/iscsi/iscsi.yaml)

## Настройка Kubernetes для работы с iSCSI и snapshot's

При создании кластера необходимо указать дополнительные параметры "feature-gates": "VolumeSnapshatDataSource=true"
```
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
metadata:
  name: config
apiServer:
  extraArgs:
    "feature-gates": "VolumeSnapshatDataSource=true"
scheduler:
  extraArgs:
    "feature-gates": "VolumeSnapshatDataSource=true"
controllerManager:
  extraArgs:
    "feature-gates": "VolumeSnapshatDataSource=true"

---
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
metadata:
  name: config
nodeRegistration:
  kubletExtraArgs:
    "feature-gates": "VolumeSnapshatDataSource=true"
```

Так же, для работы снапшотов неоходимо установить [CSI-драйвер](https://github.com/kubernetes-csi/csi-driver-host-path)
