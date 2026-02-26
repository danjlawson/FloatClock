NAME = FloatClock
APP = $(NAME).app
CONTENTS = $(APP)/Contents
MACOS = $(CONTENTS)/MacOS
RESOURCES = $(CONTENTS)/Resources

PREFIX = $(HOME)/Applications
INSTALL_PATH = $(PREFIX)/$(APP)

.PHONY: all clean install uninstall

all: $(APP)

$(APP): $(NAME).swift Info.plist
	mkdir -p $(MACOS)
	mkdir -p $(RESOURCES)
	swiftc $(NAME).swift -o $(MACOS)/$(NAME)
	cp Info.plist $(CONTENTS)/Info.plist

clean:
	rm -rf $(APP)

install: $(APP)
	mkdir -p $(PREFIX)
	cp -R $(APP) $(PREFIX)

uninstall:
	rm -rf $(INSTALL_PATH)



