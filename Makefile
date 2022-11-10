TARGETS           := $(subst /,,$(dir $(filter-out build/%,$(wildcard */chapters.txt))))
TARGETS_MP3       := $(addprefix build/,$(addsuffix .mp3,$(TARGETS)))
TARGETS_MP3_CHAPS := $(addprefix build/,$(addsuffix .chapters.txt,$(TARGETS)))

SPLIT_TARGETS       := $(patsubst %.chapters.txt,%,$(filter-out build/%,$(wildcard */*.chapters.txt)))
SPLIT_TARGETS_MP3   := $(addprefix build/,$(addsuffix .mp3,$(SPLIT_TARGETS)))
SPLIT_TARGETS_CHAPS := $(addprefix build/,$(addsuffix .chapters.txt,$(SPLIT_TARGETS)))

first_input   = $(firstword $(wildcard $(addprefix $1/,$(firstword $(filter %.mp3,$(file <$2))))))
track_num     = $(firstword $(subst -, ,$(notdir $1)))
chapter_title = $(subst _, ,$(word 2,$(subst -, ,$(notdir $1))))
total_num     = $(words $(filter $(dir $1)%,$(SPLIT_TARGETS)))

all: $(TARGETS_MP3) $(SPLIT_TARGETS_MP3)

# creates a TARGET.list.txt and TARGET.chapters.txt
$(TARGETS_MP3_CHAPS): build/%.chapters.txt: %/chapters.txt
	@mkdir -p build/tmp
	@./tool/chapter_durations build/ $< build/$*.list.txt build/$*.chapters.txt || rm build/$*.list.txt build/$*.chapters.txt

$(TARGETS_MP3): build/%.mp3: %/chapters.txt build/%.chapters.txt
	@test -e build/$*.list.txt
	@ffmpeg -f concat -i build/$*.list.txt -c copy $@
	@id3cp $(call first_input,$*,$<) $@
	@id3tag --song="Alle Kapitel" --track=1 --total=1 $@
	@cd build
	@mp3chaps -i $@

$(SPLIT_TARGETS_CHAPS): build/%.chapters.txt: %.chapters.txt
	@mkdir -p build/tmp
	@mkdir -p build/$$(dirname $*)
	@./tool/chapter_durations build/ $< build/$*.list.txt build/$*.chapters.txt || rm build/$*.list.txt build/$*.chapters.txt

$(SPLIT_TARGETS_MP3): build/%.mp3: build/%.chapters.txt
	@test -e build/$*.list.txt
	@ffmpeg -f concat -safe 0 -i build/$*.list.txt -c copy $@
	@id3cp $(call first_input,$(dir $*),$*.chapters.txt) $@
	id3tag --song="$(call chapter_title,$*)" --total=$(call total_num,$*) --track=$(call track_num,$*) $@
	@cd $$(dirname build/$*)
	@mp3chaps -i $@


clean:
	@rm -rf build
	@rm -f $(TARGETS_MP3)
	@rm -f $(TARGETS_MP3:.mp3=.chapters.txt)
	@rm -f $(TARGETS_MP3:.mp3=.list.txt)
	@rm -f $(SPLIT_TARGETS_MP3)
	@rm -f $(SPLIT_TARGETS_MP3:.mp3=.chapters.txt)
	@rm -f $(SPLIT_TARGETS_MP3:.mp3=.list.txt)
