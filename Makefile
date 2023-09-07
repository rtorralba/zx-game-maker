BIN_FOLDER=vendor/zxbne/bin/
PROJECT_NAME=z-lee

tiled-build:
	tiled --export-map json assets/maps.tmx output/maps.json
	python3 ${BIN_FOLDER}tiled-build.py

screens-build:
	python3 ${BIN_FOLDER}png2scr.py assets/screens/title.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/title.png.scr output/title.png.scr.zx0
	rm assets/screens/title.png.scr
	python3 ${BIN_FOLDER}png2scr.py assets/screens/ending.png
	java -jar ${BIN_FOLDER}zx0.jar -f assets/screens/ending.png.scr output/ending.png.scr.zx0
	rm assets/screens/ending.png.scr
	#python3 ${BIN_FOLDER}png2scr.py assets/screens/loading.png

build:
	$(MAKE) tiled-build
	$(MAKE) screens-build
	docker run --user $(id -u):$(id -g) -v ${PWD}:/app rtorralba/zxbasic -ta /app/main.bas
	cat vendor/zxbne/loader.tap main.tap assets/music.tap > output/${PROJECT_NAME}.tap
	rm -f main.tap
run:
	fuse --machine=plus2a output/${PROJECT_NAME}.tap