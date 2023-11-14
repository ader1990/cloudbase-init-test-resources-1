$global:here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ErrorActionPreference = "Stop"

Import-Module "${here}/ini.psm1"

$global:metadataService = "empty"
$cloudbaseInitRegistryPath = "HKLM:\SOFTWARE\Cloudbase Solutions\Cloudbase-Init"


function before.cloudbaseinit.plugins.common.mtu.MTUPlugin {
    "NOOP" | Should -Be "NOOP"
}

function after.cloudbaseinit.plugins.common.mtu.MTUPlugin {
    "NOOP" | Should -Be "NOOP"
}


function before.cloudbaseinit.plugins.windows.ntpclient.NTPClientPlugin {
    It "w32time service should exist" {
        { Get-Service "w32time" -ErrorAction Stop } | Should -Not -Throw
    }
}
function after.cloudbaseinit.plugins.windows.ntpclient.NTPClientPlugin {
    It "w32time service should be running" {
        $status = (Get-Service "w32time" -ErrorAction Stop).Status
        $status | Should -Be "Running"
    }
}

function before.cloudbaseinit.plugins.windows.sanpolicy.SANPolicyPlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.windows.sanpolicy.SANPolicyPlugin {
    "True" | Should -Be "True"
}
function before.cloudbaseinit.plugins.windows.displayidletimeout.DisplayIdleTimeoutConfigPlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.windows.displayidletimeout.DisplayIdleTimeoutConfigPlugin {
    "True" | Should -Be "True"
}
function before.cloudbaseinit.plugins.windows.bootconfig.BootStatusPolicyPlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.windows.bootconfig.BootStatusPolicyPlugin {
    "True" | Should -Be "True"
}
function before.cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin {
    "True" | Should -Be "True"
}
function before.cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin {
    "True" | Should -Be "True"
}
function before.cloudbaseinit.plugins.common.userdata.UserDataPlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.common.userdata.UserDataPlugin {
    "True" | Should -Be "True"
}
function before.cloudbaseinit.plugins.windows.winrmlistener.ConfigWinRMListenerPlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.windows.winrmlistener.ConfigWinRMListenerPlugin {
    "True" | Should -Be "True"
}
function before.cloudbaseinit.plugins.common.localscripts.LocalScriptsPlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.common.localscripts.LocalScriptsPlugin {
    "True" | Should -Be "True"
}
function before.cloudbaseinit.plugins.common.trim.TrimConfigPlugin {
    "True" | Should -Be "True"
}
function after.cloudbaseinit.plugins.common.trim.TrimConfigPlugin {
    "True" | Should -Be "True"
}

BeforeDiscovery {
    $global:metadataService | Should -Be "empty"
    $metadataServiceConfigFile = Resolve-Path "$here/../$metadataService/cloudbase-init.conf"
    $pluginList = Get-IniFileValue -Path $metadataServiceConfigFile -Section "DEFAULT" `
                                      -Key "plugins" `
                                      -Default ""
    $pluginList = $pluginList.Split(",")
}

Describe "TestVerifyBeforeAllPlugins" {
    $pluginList | ForEach-Object {
        $plugin = $_
        if (!$plugin) {
            return
        }
        & "before.${plugin}"

        It "Checks for Registry Key state ${plugin}" {
            $propertyName = "TEST"
            $propertyValue = "NOT_INITIALIZED"
            try {
                $propertyValue = Get-ItemProperty -Path $cloudbaseInitRegistryPath -Name $propertyNameopertyName -ErrorAction "Stop"
            } catch {
                $propertyValue = "NOT_EXISTENT"
            }
            $propertyValue | Should -BeExactly "NOT_EXISTENT"
        }
    }
}

Describe "TestVerifyAfterAllPlugins" {
    $pluginList | ForEach-Object {
        $plugin = $_
        if (!$plugin) {
            return
        }
        & "after.${plugin}"

        It "Checks for Registry Key state ${plugin}" {
            $propertyName = "TEST"
            $propertyValue = "NOT_INITIALIZED"
            try {
                $propertyValue = Get-ItemProperty -Path $cloudbaseInitRegistryPath -Name $propertyNameopertyName -ErrorAction "Stop"
            } catch {
                $propertyValue = "NOT_EXISTENT"
            }
            $propertyValue | Should -BeExactly "NOT_EXISTENT"
        }
    }
}
