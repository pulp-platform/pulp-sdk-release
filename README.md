## SDK release download

This section is only relevant if all the packages can be downloaded precompiled. If you don't have access to the artifactory server, follow the other sections to build the packages.
This is reserved for internal PULP team usage, more information can be retrieved on this [project](https://iis-git.ee.ethz.ch/pulp-sw/pulp-sdk-internal).

### Prerequisites

On Ubuntu 16.04, you have to install the following prerequisites to be able to use the PULP SDK:

    sudo apt-get install -y build-essential git libftdi-dev libftdi1 doxygen python3-pip libsdl2-dev curl

### Getting the top repositories

As this method of getting the SDK allows selecting the SDK amongst several releases, you must
first get this top repository which knows which releases are available:

    git clone https://github.com/pulp-platform/pulp-sdk-release.git
    cd pulp-sdk-release


### Package server configuration

To download the dependencies, the access to the package server (Artifactory) must be configured. This is reserved for internal usage, more information can be retrieved on this [project]( https://iis-git.ee.ethz.ch/pulp-sw/pulp-sdk-internal). Be careful to configure the artifactory credentials using the .wgetrc file as the packages will be downloaded through wget.

The build process will try to download packages suitable for the detected Linux distribution. In case this is not suitable, you can force the distribution to be used by defining this environment variable:

    export PULP_ARTIFACTORY_DISTRIB=<distrib>

This can currently be `CentOS_7` or `Ubuntu_16`. If your distribution is not supported, you can try
to download the packages for a distribution which is close to yours.

You can also specify the distribution on the command-line when invoking make:

    make list distrib=Ubuntu_16

### SDK and dependency download

You can get the list of available SDKs for the distribution you selected with this command:

    make list

Then you can download the SDK you want by executing the following command with the appropriate
SDK version:

    make version=<version> get

You should see packages being downloaded through wget. Otherwise there is probably something wrong
with the artifactory server configuration.

Once the SDK is downloaded, you have to source the file indicated in the terminal to setup the downloaded SDK.



### Target and platform selection

Once the SDK is selected, you can get the list of supported targets with this command:

    make targets

Before using the SDK, you have to configure it for a specific target by sourcing the file
indicated next to the target you want to select.

You have to do the same for the platform you want to use, and you can get the list of platforms
with this command:

    make platforms
    
### PULP-based board setup
The PULP SDK requires the FTDI driver to be correctly configured to work properly.
To install them for a PULP-based board, you can do the following (requires administrator rights):

    sudo ln -s /usr/bin/libftdi-config /usr/bin/libftdi1-config
    sudo usermod -a -G dialout YOUR_USER_NAME
    touch 90-ftdi_pulp.rules
    echo 'ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666", GROUP="dialout"'> 90-ftdi_pulp.rules
    sudo mv 90-ftdi_pulp.rules /etc/udev/rules.d/
    sudo udevadm control --reload-rules && sudo udevadm trigger

After this, open a new terminal and source the SDK as explained above.
