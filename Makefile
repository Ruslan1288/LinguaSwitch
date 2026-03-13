.PHONY: build run clean test installer

build:
	swift build -c release

debug:
	swift build

run: debug
	.build/debug/LayoutSwitcher

clean:
	swift package clean
	rm -rf .build

test:
	swift test

installer:
	zsh build_installer.sh
