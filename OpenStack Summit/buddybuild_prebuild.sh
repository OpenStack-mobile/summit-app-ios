# Install Carthage dependencies for watchOS and tvOS
carthage bootstrap --platform watchOS --verbose --toolchain com.apple.dt.toolchain.Swift_2_3
carthage bootstrap --platform tvOS --verbose --toolchain com.apple.dt.toolchain.Swift_2_3
