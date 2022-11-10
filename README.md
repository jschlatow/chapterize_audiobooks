# Summary

This repository hosts tools for adding chapter information to audiobooks. It
was motivated by a particular book, which was split into hundreds of short files
without metadata. Luckily, these chunks were aligned with sub sub sections of
the book. The tooling here thus consists in metadata about what chapter is
composed of what files along with some scripts that generate a single mp3 with
chapter metadata.


# Usage

Each audiobook must be hosted in a separate directory. This directory hosts
one or multiple txt files that contain the chapter information. The audio files
must also be copied into this directory. There are two modes of operation.


## Monolithic mode

In this mode, a single output file (mp3) is generated. To use this mode, add
a _chapters.txt_ to the audiobook's directory. Each line in this file specifies
a chapter in the following format:

```
Chapter title/Section title/Subsection title: first_file.mp3 second_file.mp3
```

The part before the colon (`:`) specifies the chapter title. Hierarchy levels are
subdivided by a `/`. The part after the colon is a space-separated list of
input files. The list supports wildcard notation (e.g. `01*.mp3`). The files
are searched for in the directory of the _chapters.txt_ file.

## Split mode

In this mode, multiple output files are generated. To use this mode, add files
according to this pattern: `number-title.chapters.txt`.
The files content follow the same syntax as the _chapters.txt_ (see
Monolithic mode).


# Troubleshooting

* On Android, the chapter marks are very inaccurate. This supposedly has
  something to do with how the system's audio backend computes timestamps
  within an audio file and is therefore independent of the app. The longer the
  audio file is the more inaccurate the chapter marks become. For these devices
  it is better to split the book into several audio files.
