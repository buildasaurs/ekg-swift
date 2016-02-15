build:
	@echo "Building ekg-swift"
	@swift build

run: build
	.build/debug/ekg-swift

clean: 
	rm -fr .build Packages