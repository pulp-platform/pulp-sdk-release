SHELL=bash

distrib ?= $(shell lsb_release -i -s)_$(firstword $(subst ., ,$(shell lsb_release -r -s)))

ifneq '$(profile)' ''
profileName=$(profile)-
else
profile=default
endif

ARTIFACT_DIR=artifacts/$(profile)/$(distrib)

ifdef alias
alias_opt = --alias=sdk:$(alias)
sdk_version = $(alias)
else
sdk_version = $(sdk)
endif

export PULP_SDK_SRC_PATH=$(CURDIR)/src/sdk/$(sdk_version)

help:

	@echo "Available make targets:"
	@echo "  list               Shows the available SDK versions."
	@echo "  sdk                Shows the installed SDK versions."
	@echo "  profiles           Shows the available profiles."
	@echo "  get                Downloads the active SDK. See the options for specifying the active SDK."
	@echo "  src                Fetches the active SDK sources. See the options for specifying the active SDK."
	@echo "  deps               Gets dependencies needed for building SDK. See the options for specifying the active SDK."
	@echo "  build              Builds the active SDK from sources. See the options for specifying the active SDK."
	@echo "  build.runtime      Builds only the runtime part."
	@echo "  build.platform     Builds only the platform part."

	@echo
	@echo "Available make options (other configuration options are available, see make config):"
	@echo "  version=<version>      Specifies the active SDK version, which must match one of the SDK list"
	@echo "  distrib=<version>  Specifies Linux distribution for which the packages must be downloaded. If not specified, it is guessed from lsb_release"
	@echo "  profile=<profile>  Specifies the profile. The default one is the main one, supporting all targets (must not be used with this option). Other profiles are provided for specific targets or specific needs."

list:
	@echo "Available SDK versions:"
	@for sdk in `ls $(ARTIFACT_DIR)`; do  \
		version=`echo $$sdk | sed s/get-sdk-// | sed s/-$(distrib).py//`; \
		printf "  %-15s %s\n" "$$version" "make version=$$version get"; \
	done

sdk:
	@echo "Installed SDK versions:"
	@for sdk in `ls pkg/sdk`; do  \
		printf "  %-15s %s\n" "$$sdk" "env/env-sdk-$$sdk.sh"; \
	done

targets:
	@echo "Available targets:"
	@for file in `ls $$PULP_SDK_HOME/configs/*.sh | grep -v platform`; do  \
		target=`echo $$file | sed s#$$PULP_SDK_HOME/configs/## | sed s/.sh//`; \
		file=`echo $$file | sed s#$(CURDIR)/##`; \
		printf "  %-30s %s\n" "$$target" "$$file"; \
	done

platforms:
	@echo "Available platforms:"
	@for file in `ls $$PULP_SDK_HOME/configs/platform*.sh`; do  \
		target=`echo $$file | sed s#$$PULP_SDK_HOME/configs/platform-## | sed s/.sh//`; \
		file=`echo $$file | sed s#$(CURDIR)/##`; \
		printf "  %-30s %s\n" "$$target" "$$file"; \
	done

profiles:
	@for profile in `ls artifacts`; do  \
		echo $$profile; \
	done

ifndef sdk

get:
	@echo "The SDK version must be specified through sdk=<version>. Execute \"make list\" to see the available versions."
	@exit 1

src: get

build: get

else

src:	
	@echo "Getting sources for SDK $(sdk_version)"
	@echo
	@mkdir -p src/sdk
	@if [ -e src/sdk/$(sdk_version) ]; then cd src/sdk/$(sdk_version); git fetch -t; git checkout $(sdk); else git clone git@iis-git.ee.ethz.ch:pulp-sw/pulp_pipeline.git src/sdk/$(sdk); cd src/sdk/$(sdk); git checkout $(sdk); fi
	@./$(ARTIFACT_DIR)/get-sdk-$(sdk)-$(distrib).py env $(alias_opt)
	@source src/sdk/$(sdk_version)/init.sh && plpbuild --p sdk checkout
	@echo
	@echo "Done, you must now source one of these files before compiling the SDK: env/env-sdk-$(sdk_version).sh or env/env-sdk-$(sdk_version).csh"

deps:
	@echo "Getting dependencies for SDK $(sdk_version)"
	@echo
	@source src/sdk/$(sdk_version)/init.sh && unset profile && unset MAKEFLAGS && plpbuild --p sdk deps --stdout

clean:
	@echo "Cleaning SDK $(sdk_version)"
	@echo
	@source src/sdk/$(sdk_version)/init.sh && unset profile && unset MAKEFLAGS && plpbuild --p sdk clean --stdout

build:
	@echo "Building SDK $(sdk_version)"
	@echo
	@source src/sdk/$(sdk_version)/init.sh && unset profile && unset MAKEFLAGS && plpbuild --p sdk build --stdout

build.runtime:
	@echo "Building SDK runtimes $(sdk_version)"
	@echo
	@source src/sdk/$(sdk_version)/init.sh && unset profile && unset MAKEFLAGS && plpbuild --g runtime build --stdout

build.platform:
	@echo "Building SDK platforms $(sdk_version)"
	@echo
	@source src/sdk/$(sdk_version)/init.sh && unset profile && unset MAKEFLAGS && plpbuild --g platform build --stdout

get:
	@echo "Downloading SDK $(sdk_version)"
	@echo
	@./$(ARTIFACT_DIR)/get-sdk-$(sdk)-$(distrib).py $(alias_opt)
	@mkdir -p doc
	@rm -f doc/$(sdk_version) && ln -s ../pkg/sdk/$(sdk_version)/doc/html doc/$(sdk_version)
	@echo 
	@echo "Done, this SDK can now be used by sourcing one of these files: env/env-sdk-$(sdk_version).sh or env/env-sdk-$(sdk_version).csh"
	@echo "The documentation can be found here: doc/$(sdk_version)/sdk/index.html"

endif

.PHONY: src build get list help
