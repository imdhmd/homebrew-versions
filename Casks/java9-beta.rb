cask 'java9-beta' do
  version '1.9,174'
  sha256 '26bc393ebf422edf9ffb04a92e5be604b390e13eb532c12eba9f0ad20d5ef4ba'

  url "http://download.java.net/java/jdk#{version.before_comma.minor}/archive/#{version.after_comma}/binaries/jdk-#{version.before_comma.minor}-ea+#{version.after_comma}_osx-x64_bin.dmg",
      cookies: { 'oraclelicense' => 'accept-securebackup-cookie' }
  name 'Java Standard Edition Development Kit'
  homepage 'http://jdk.java.net/9/'

  pkg 'JDK 9.pkg'

  postflight do
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string BundledApp', "/Library/Java/JavaVirtualMachines/jdk-#{version.minor}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string JNI', "/Library/Java/JavaVirtualMachines/jdk-#{version.minor}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string WebStart', "/Library/Java/JavaVirtualMachines/jdk-#{version.minor}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/usr/libexec/PlistBuddy',
                   args: ['-c', 'Add :JavaVM:JVMCapabilities: string Applets', "/Library/Java/JavaVirtualMachines/jdk-#{version.minor}.jdk/Contents/Info.plist"],
                   sudo: true
    system_command '/bin/mkdir',
                   args: ['-p', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.minor}.jdk/Contents/Home/bundle/Libraries"],
                   sudo: true
    system_command '/bin/ln',
                   args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.minor}.jdk/Contents/Home/lib/server/libjvm.dylib", "/Library/Java/JavaVirtualMachines/jdk-#{version.minor}.jdk/Contents/Home/bundle/Libraries/libserver.dylib"],
                   sudo: true

    if MacOS.version <= :mavericks
      system_command '/bin/rm',
                     args: ['-rf', '--', '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK'],
                     sudo: true
      system_command '/bin/ln',
                     args: ['-nsf', '--', "/Library/Java/JavaVirtualMachines/jdk-#{version.minor}.jdk/Contents", '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK'],
                     sudo: true
    end
  end

  uninstall pkgutil: 'com.oracle.jdk-9',
            delete:  [
                       MacOS.version <= :mavericks ? '/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK' : '',
                     ].keep_if { |v| !v.empty? }

  zap       delete: [
                      '~/Library/Application Support/Oracle/Java',
                      '~/Library/Caches/com.oracle.java.Java-Updater',
                      '~/Library/Caches/net.java.openjdk.cmd',
                    ],
            rmdir:  '~/Library/Application Support/Oracle/'

  caveats <<-EOS.undent
    This Cask makes minor modifications to the JRE to prevent any packaged
    application issues.

    If your Java application still asks for JRE installation, you might need to
    reboot or logout/login.

    The JRE packaging bug is discussed here:

        https://bugs.eclipse.org/bugs/show_bug.cgi?id=411361

    Installing this Cask means you have AGREED to the Oracle Binary Code License
    Agreement for Java SE at

        http://www.oracle.com/technetwork/java/javase/terms/license/index.html

    EOS
end
