.PHONY: build run clean test

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
