ROOT ?= $(shell 'pwd')

IMAGE_NAME ?= alpine-x86

DOCKER_RUN ?= docker container run --platform linux/386 --rm -v $(ROOT):/app $(IMAGE_NAME)

.DEFAULT_GOAL := run
INPUT_FILE_NAME ?= $(input)
INPUT_ASM ?= $(asm)
OUTPUT_FILE_NAME ?= $(shell echo "$$(echo $$(cut -d'.' -f1 <<< $(INPUT_ASM)))")

$(VERBOSE).SILENT:

ifndef INPUT_FILE_NAME
$(error "required input=value")
endif
ifndef INPUT_ASM
$(error "required asm=value")
endif


asm-build:
	nasm -f elf32 $(INPUT_ASM) -o $(OUTPUT_FILE_NAME).o
	ld -o $(OUTPUT_FILE_NAME) $(OUTPUT_FILE_NAME).o
	rm -rf $(OUTPUT_FILE_NAME).o

asm-run: asm-build
	./$(OUTPUT_FILE_NAME) $(INPUT_FILE_NAME)

build:
	docker image build -t $(IMAGE_NAME) .

run: build
	$(DOCKER_RUN) asm-run INPUT_FILE_NAME=$(INPUT_FILE_NAME) OUTPUT_FILE_NAME=$(OUTPUT_FILE_NAME) INPUT_ASM=$(INPUT_ASM)
