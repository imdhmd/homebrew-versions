cask 'virtualbox-extension-pack-beta' do
  version '5.1.23-116259'
  sha256 '51fbc13865542287a8008674450f6be527f3d052a50f2830531a17c1f3ad22fe'

  url "https://www.virtualbox.org/download/testcase/Oracle_VM_VirtualBox_Extension_Pack-#{version}.vbox-extpack"
  name 'Oracle VirtualBox Extension Pack'
  homepage 'https://www.virtualbox.org/'

  depends_on cask: 'virtualbox-beta'
  container type: :naked

  stage_only true

  postflight do
    system_command '/usr/local/bin/VBoxManage',
                   args: [
                           'extpack', 'install',
                           '--replace', "#{staged_path}/Oracle_VM_VirtualBox_Extension_Pack-#{version}.vbox-extpack",
                           '--accept-license=715c7246dc0f779ceab39446812362b2f9bf64a55ed5d3a905f053cfab36da9e'
                         ],
                   sudo: true
  end

  uninstall_postflight do
    system_command '/usr/local/bin/VBoxManage',
                   args: [
                           'extpack', 'uninstall',
                           'Oracle VM VirtualBox Extension Pack'
                         ],
                   sudo: true
  end

  caveats <<-EOS.undent
    Installing this Cask means you have AGREED to the
    VirtualBox Personal Use and Evaluation License at

    https://www.virtualbox.org/wiki/VirtualBox_PUEL
  EOS
end
