#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;
use Test::Exception;
use FusionInventory::VMware::SOAP;
use File::Basename;

use Data::Dumper;

my %test = (
    'esx-4.1.0-1' => {
        'connect()' => [
          {
            'lastActiveTime' => '1970-01-25T03:53:04.326969+01:00',
            'loginTime' => '1970-01-25T03:53:04.326969+01:00',
            'fullName' => 'root',
            'messageLocale' => 'en',
            'locale' => 'en',
            'userName' => 'root',
            'key' => '52eec005-5d13-dfae-afd8-7e1b4561a154'
          }
        ],
        'getHostname()' => 'esx-test.teclib.local',
        'getBiosInfo()' => {
          'SMANUFACTURER' => 'Sun Microsystems',
          'SMODEL' => 'Sun Fire X2200 M2 with Dual Core Processor',
          'BDATE' => '2009-02-04T00:00:00Z',
          'ASSETTAG' => ' To Be Filled By O.E.M.',
          'BVERSION' => 'S39_3B27'
        },
        'getHardwareInfo()' => {
          'OSCOMMENTS' => 'VMware ESX 4.1.0 build-260247',
          'NAME' => 'esx-test',
          'OSVERSION' => '4.1.0',
          'WORKGROUP' => 'teclib.local',
          'MEMORY' => 8190,
          'OSNAME' => 'VMware ESX',
          'UUID' => 'b5bfd78a-fa79-0010-adfe-001b24f07258',
          'DNS' => '10.0.5.105'
        },
        'getCPUs()' => [
          {
            'NAME' => 'Dual-Core AMD Opteron(tm) Processor 2218',
            'MANUFACTURER' => 'AMD',
            'SPEED' => 2613,
            'THREAD' => '1',
            'CORE' => 2
          },
          {
            'NAME' => 'Dual-Core AMD Opteron(tm) Processor 2218',
            'MANUFACTURER' => 'AMD',
            'SPEED' => 2613,
            'THREAD' => '1',
            'CORE' => 2
          }
        ],
        'getControllers()' => [
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '500',
            'NAME' => 'MCP55 Memory Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0369',
            'PCISLOT' => '00:00.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '601',
            'NAME' => 'MCP55 LPC Bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0364',
            'PCISLOT' => '00:01.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => 'c05',
            'NAME' => 'MCP55 SMBus',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0368',
            'PCISLOT' => '00:01.1'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => 'c03',
            'NAME' => 'MCP55 USB Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:036c',
            'PCISLOT' => '00:02.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => 'c03',
            'NAME' => 'MCP55 USB Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:036d',
            'PCISLOT' => '00:02.1'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '101',
            'NAME' => 'NVidia NForce MCP55 IDE/PATA Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:036e',
            'PCISLOT' => '00:04.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '101',
            'NAME' => 'MCP55 SATA Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:037f',
            'PCISLOT' => '00:05.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0370',
            'PCISLOT' => '00:06.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '680',
            'NAME' => 'nVidia NForce Network Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0373',
            'PCISLOT' => '00:08.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '680',
            'NAME' => 'nVidia NForce Network Controller',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0373',
            'PCISLOT' => '00:09.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0376',
            'PCISLOT' => '00:0a.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0374',
            'PCISLOT' => '00:0b.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0374',
            'PCISLOT' => '00:0c.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0378',
            'PCISLOT' => '00:0d.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '604',
            'NAME' => 'MCP55 PCI Express bridge',
            'MANUFACTURER' => 'nVidia Corporation',
            'PCIID' => '10de:0377',
            'PCISLOT' => '00:0f.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] HyperTransport Technology Configuration',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1100',
            'PCISLOT' => '00:18.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] Address Map',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1101',
            'PCISLOT' => '00:18.1'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] DRAM Controller',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1102',
            'PCISLOT' => '00:18.2'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] Miscellaneous Control',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1103',
            'PCISLOT' => '00:18.3'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] HyperTransport Technology Configuration',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1100',
            'PCISLOT' => '00:19.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] Address Map',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1101',
            'PCISLOT' => '00:19.1'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] DRAM Controller',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1102',
            'PCISLOT' => '00:19.2'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '600',
            'NAME' => 'K8 [Athlon64/Opteron] Miscellaneous Control',
            'MANUFACTURER' => 'Advanced Micro Devices [AMD]',
            'PCIID' => '1022:1103',
            'PCISLOT' => '00:19.3'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '300',
            'NAME' => 'ASPEED Graphics Family',
            'MANUFACTURER' => 'ASPEED Technology, Inc.',
            'PCIID' => '1a03:2000',
            'PCISLOT' => '01:05.0'
          },
          {
            'PCISUBSYSTEMID' => '',
            'PCICLASS' => '604',
            'NAME' => 'EPB PCI-Express to PCI-X Bridge',
            'MANUFACTURER' => 'Broadcom',
            'PCIID' => '1166:0103',
            'PCISLOT' => '05:00.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '200',
            'NAME' => 'Broadcom BCM5715 Gigabit Ethernet',
            'MANUFACTURER' => 'Broadcom Corporation',
            'PCIID' => '14e4:1678',
            'PCISLOT' => '06:04.0'
          },
          {
            'PCISUBSYSTEMID' => '108e:534b',
            'PCICLASS' => '200',
            'NAME' => 'Broadcom BCM5715 Gigabit Ethernet',
            'MANUFACTURER' => 'Broadcom Corporation',
            'PCIID' => '14e4:1678',
            'PCISLOT' => '06:04.1'
          }
        ],
        'getNetworks()' => [
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => '00:1b:24:f0:6a:45',
            'DESCRIPTION' => 'vmnic0',
            'SPEED' => '',
            'PCISLOT' => '00:08.0',
            'IPADDRESS' => undef,
            'DRIVER' => 'forcedeth'
          },
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => '00:1b:24:f0:6a:46',
            'DESCRIPTION' => 'vmnic1',
            'SPEED' => '',
            'PCISLOT' => '00:09.0',
            'IPADDRESS' => undef,
            'DRIVER' => 'forcedeth'
          },
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => '00:1b:24:f0:6a:43',
            'DESCRIPTION' => 'vmnic2',
            'SPEED' => '100',
            'PCISLOT' => '06:04.0',
            'IPADDRESS' => undef,
            'DRIVER' => 'tg3'
          },
          {
            'IPMASK' => undef,
            'STATUS' => 'Down',
            'MACADDR' => '00:1b:24:f0:6a:44',
            'DESCRIPTION' => 'vmnic3',
            'SPEED' => '',
            'PCISLOT' => '06:04.1',
            'IPADDRESS' => undef,
            'DRIVER' => 'tg3'
          },
          {
            'IPMASK' => undef,
            'VIRTUALDEV' => '1',
            'STATUS' => 'Down',
            'MACADDR' => undef,
            'SPEED' => '',
            'PCISLOT' => undef,
            'DRIVER' => undef,
            'DESCRIPTION' => 'vmk0',
            'IPADDRESS' => undef
          },
          {
            'MTU' => undef,
            'IPMASK' => '255.255.0.0',
            'VIRTUALDEV' => '1',
            'STATUS' => 'Up',
            'MACADDR' => '00:50:56:4e:eb:6f',
            'DESCRIPTION' => 'vswif0',
            'IPADDRESS' => '10.0.2.190'
          },
          {
            'MTU' => undef,
            'IPMASK' => '255.255.0.0',
            'VIRTUALDEV' => '1',
            'STATUS' => 'Up',
            'MACADDR' => '00:50:56:75:f7:2e',
            'DESCRIPTION' => 'vmk0',
            'IPADDRESS' => '10.0.2.189'
          }
        ],
        'getStorages()' => [
          {
            'NAME' => '/vmfs/devices/cdrom/mpx.vmhba0:C0:T0:L0',
            'FIRMWARE' => '1.AC',
            'TYPE' => 'cdrom',
            'DISKSIZE' => undef,
            'SERIAL' => undef,
            'DESCRIPTION' => 'Local TEAC CD-ROM (mpx.vmhba0:C0:T0:L0)',
            'MANUFACTURER' => 'TEAC    ',
            'MODEL' => 'DV-28E-V        '
          },
          {
            'NAME' => '/vmfs/devices/disks/t10.ATA_____ST3250310NS_________________________________________9SF1F0TH',
            'FIRMWARE' => 'SN06',
            'TYPE' => 'disk',
            'DISKSIZE' => '250059350.016',
            'SERIAL' => '3232323232323232323232325783704970488472',
            'DESCRIPTION' => 'Local ATA Disk (t10.ATA_____ST3250310NS_________________________________________9SF1F0TH)',
            'MANUFACTURER' => 'Seagate',
            'MODEL' => 'ST3250310NS     '
          }

        ],
        'getDrives()' => [
          {
            'VOLUMN' => undef,
            'NAME' => 'datastore1',
            'TOTAL' => 248571,
            'SERIAL' => '4d3ea5ac-45d89fb1-847e-001b24f06a45',
            'TYPE' => '/vmfs/volumes/4d3ea5ac-45d89fb1-847e-001b24f06a45',
            'FILESYSTEM' => 'vmfs'
          },
          {
            'VOLUMN' => 'stockage1.teclib.local:/mnt/datastore/VmwareISO',
            'NAME' => 'ISO-datastore',
            'TOTAL' => 53687,
            'SERIAL' => undef,
            'TYPE' => '/vmfs/volumes/6954b300-01710358',
            'FILESYSTEM' => 'nfs'
          }
        ],
       'getVirtualMachines()' => [
          {
            'NAME' => 'ubuntu',
            'STATUS' => 'running',
            'COMMENT' => '',
            'MAC' => '00:0c:29:06:42:d8',
            'VMID' => '16',
            'VMTYPE' => 'VMware',
            'MEMORY' => '512',
            'UUID' => '564d9904-a176-a762-1b95-f75ddd0642d8',
            'VCPU' => '1'
          },
          {
            'NAME' => 'windows',
            'STATUS' => 'running',
            'COMMENT' => '',
            'MAC' => '00:0c:29:58:44:c8',
            'VMID' => '32',
            'VMTYPE' => 'VMware',
            'MEMORY' => '256',
            'UUID' => '564d0750-3ae1-d18d-1613-eb489b5844c8',
            'VCPU' => '1'
          },
          {
            'NAME' => 'solaris',
            'STATUS' => 'running',
            'COMMENT' => '',
            'MAC' => '00:0c:29:5f:64:60',
            'VMID' => '48',
            'VMTYPE' => 'VMware',
            'MEMORY' => '4096',
            'UUID' => '564df277-de0f-b401-0060-7d6a675f6460',
            'VCPU' => '2'
          },
          {
            'NAME' => 'Nouvelle machine virtuelle',
            'STATUS' => 'off',
            'COMMENT' => '',
            'MAC' => '',
            'VMID' => '64',
            'VMTYPE' => 'VMware',
            'MEMORY' => '512',
            'UUID' => '564d79a4-7ea6-3423-2980-0c882a78f698',
            'VCPU' => '1'
          }
        ]
    },
);
plan tests => 12;

foreach my $dir (glob('resources/*')) {
    my $testName = basename($dir);
    my $vpbs = FusionInventory::VMware::SOAP->new({
    debugDir => $dir,
    user => 'foo',
    });

    my $ret;
    lives_ok{$ret = $vpbs->connect('foo', 'bar')} $testName.' connect()';
    is_deeply($ret, $test{$testName}{'connect()'}, 'connect()') or print  Dumper($ret);

    lives_ok{$ret = $vpbs->getHostFullInfo()} $testName.' getHostFullInfo()';

    foreach my $func (qw(getHostname getBiosInfo getHardwareInfo getCPUs getControllers getNetworks getStorages getDrives getVirtualMachines)) {
        is_deeply($ret->$func, $test{$testName}{"$func()"}, "$func()") or print "####\n". Dumper($ret->$func)."####\n";

    }

}