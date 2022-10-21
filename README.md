<div id="top"></div>

[![OS-Windows]][OS-Windows]
[![OS-Linux]][OS-Linux]
[![OS-MacOS]][OS-MacOS]

<br/>
<div align="center">
<h2 align="center">Cat_For_Windows</h2>
   <p align="center">
      Simple Command-line Tool made in AutoIt & Python
      <br/>
      <a href="https://github.com/SilenZcience/Cat_For_Windows/blob/main/Python/src/cat.py">
         <strong>Explore the code »</strong>
      </a>
      <br/>
      <br/>
      <a href="https://github.com/SilenZcience/Cat_For_Windows/issues">Report Bug</a>
      ·
      <a href="https://github.com/SilenZcience/Cat_For_Windows/issues">Request Feature</a>
   </p>
</div>


<details>
   <summary>Table of Contents</summary>
   <ol>
      <li>
         <a href="#about-the-project">About The Project</a>
         <ul>
            <li><a href="#made-with">Made With</a></li>
         </ul>
      </li>
      <li>
         <a href="#getting-started">Getting Started</a>
         <ul>
            <li><a href="#prerequisites">Prerequisites</a></li>
            <li><a href="#installation">Installation</a></li>
         </ul>
      </li>
      <li><a href="#usage">Usage</a>
         <ul>
         <li><a href="#examples">Examples</a></li>
         </ul>
      </li>
      <li><a href="#license">License</a></li>
      <li><a href="#contact">Contact</a></li>
   </ol>
</details>

## About The Project

This project copies the fundamental framework of the cat command-line tool from linux and translates its features to
a windows executable file.

Additionally it includes the feature to strip and reverse the content of any given file, make use of the standard-input, which enables cat piping into each other, generating the checksum of any file, and even convert decimal, hexadecimal and binary numbers within any text.

### Made With
[![AutoIt][MadeWith-AutoIt]](https://www.autoitscript.com/site)
[![Python][MadeWith-Python]](https://www.python.org/)

<p align="right">(<a href="#top">back to top</a>)</p>

## Getting Started

### Prerequisites

No Prerequisites are neccessary; The stand-alone executable `cat.exe` is sufficient.

> :warning: **You should never trust any executable file!**

> AutoIt executables are known for getting **misidentified** as a **virus**. In this case you will need to exclude the binary-file from any antivirus software installed. Feel free to read/compile the [cat.au3](src/cat.au3) yourself using the official [Aut2Exe Converter](https://www.autoitscript.com/site/autoit/downloads/).

### Installation

1. Clone the repository and move into the root\AutoIt\bin directory with:


```console
git clone git@github.com:SilenZcience/Cat_For_Windows.git
cd Cat_For_Windows\AutoIt\bin
```
or use the python version with:
```console
git clone git@github.com:SilenZcience/Cat_For_Windows.git
cd Cat_For_Windows\Python\bin
```
2. Add the directory to your system-environment `PATH`-variables.

or simply
```console
pip install cat-win
```
(reference: [cat_win](https://github.com/SilenZcience/cat_win))

<p align="right">(<a href="#top">back to top</a>)</p>

## Usage

1. run the following command in any cmd:

```console
cat --help
```

### Examples

![](img/help.png?raw=true "help.png")

![](img/example1.png?raw=true "example1.png")

![](img/example2.png?raw=true "example2.png")

<p align="right">(<a href="#top">back to top</a>)</p>

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/SilenZcience/Cat_For_Windows/blob/main/LICENSE) file for details

## Contact

> **SilenZcience** <br/>
[![GitHub-SilenZcience][GitHub-SilenZcience]](https://github.com/SilenZcience)

[OS-Windows]: https://svgshare.com/i/ZhY.svg
[OS-Linux]: https://svgshare.com/i/Zhy.svg
[OS-MacOS]: https://svgshare.com/i/ZjP.svg

[MadeWith-AutoIt]: https://img.shields.io/badge/Made%20with-AutoIt-brightgreen
[MadeWith-Python]: https://img.shields.io/badge/Made%20with-Python-brightgreen

[Warning]: https://img.shields.io/badge/warning-orange?style=for-the-badge

[GitHub-SilenZcience]: https://img.shields.io/badge/GitHub-SilenZcience-orange
