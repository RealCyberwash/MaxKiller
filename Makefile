.PHONY: setup native native-universal clean test gen watch

NATIVE_DIR := $(abspath build/native)
BUILD_TYPE ?= Release
UNIVERSAL ?= OFF

setup:
	git submodule update --init --recursive
	@dart pub get
	$(MAKE) gen
	$(MAKE) native

native:
	@cmake -S . -B .cmake-release -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DNATIVE_UNIVERSAL=$(UNIVERSAL) -DOUT_BASE="$(NATIVE_DIR)"
	@cmake --build .cmake-release --config $(BUILD_TYPE) --parallel

native-universal:
	@$(MAKE) native UNIVERSAL=ON BUILD_TYPE=$(BUILD_TYPE)

clean:
	@rm -rf .cmake-release "$(NATIVE_DIR)"

test: native
	@dart pub get
	@dart test

gen:
	flutter pub get
	flutter pub run build_runner build -d

watch:
	flutter pub get
	flutter pub run build_runner watch -d