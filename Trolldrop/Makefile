TARGET 	= Trolldrop
PORT	= 2222
IP	= 127.0.0.1

.PHONY: all clean

build:
	xcodebuild ARCHS=arm64 clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO -sdk iphoneos -configuration Debug

stage:
	mkdir -p build/latest/Applications/
	mkdir -p build/latest/DEBIAN/
	cp -R ../control build/latest/DEBIAN/
	#cp -R ./postinst build/latest/DEBIAN/
	cp -R build/Debug-iphoneos/$(TARGET).app build/latest/Applications/
	rm -rf build/latest/Applications/$(TARGET).app/Frameworks/*.dylib
	ldid2 -Sent.xml build/latest/Applications/$(TARGET).app/$(TARGET)

package: stage
	dpkg-deb -bZxz build/latest/ ./$(TARGET)_latest.deb
	rm -rf build/latest

install: stage
	scp -P $(PORT) -r build/latest/Applications/$(TARGET).app root@$(IP):/Applications

install-package:
	scp -P $(PORT) -r $(TARGET)_latest.deb root@$(IP):/tmp/$(TARGET)_latest.deb
	ssh -p $(PORT) root@$(IP) dpkg -i /tmp/$(TARGET)_latest.deb
	ssh -p $(PORT) root@$(IP) uicache

do: build package install-package

do-no-build: package install-package

clean:
	rm -rf build
