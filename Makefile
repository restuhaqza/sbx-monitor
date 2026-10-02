.PHONY: build app run dev icon install uninstall clean

APP_DIR ?= /Applications

# Compile the Swift package.
build:
	swift build

# Regenerate the app icon (Resources/AppIcon.icns) from the vector source.
icon:
	./make_icon.sh

# Assemble dist/SbxMonitor.app and launch it.
app:
	./build_app.sh
	open dist/SbxMonitor.app

# Quick dev loop: rebuild + relaunch the bundled app.
run: app

# Run the raw executable (no app bundle; menu bar item may not appear).
dev:
	swift run

# Build and copy into /Applications (stable path for launch-at-login), then launch.
install:
	./build_app.sh
	rm -rf "$(APP_DIR)/SbxMonitor.app"
	cp -R dist/SbxMonitor.app "$(APP_DIR)/"
	open "$(APP_DIR)/SbxMonitor.app"

# Quit and remove the installed app (also unregisters its login item).
uninstall:
	-pkill -x SbxMonitor
	rm -rf "$(APP_DIR)/SbxMonitor.app"

clean:
	rm -rf .build dist
