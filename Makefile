build:
	@echo "Building ekg-swift"
	@swift build

debug: build
	lldb .build/debug/ekg-swift

run: build
	.build/debug/ekg-swift

clean: 
	rm -fr .build Packages