## About
A high precision Decimal/Binary converter written in Free Pascal

## Features
- User - friendly interface
- Support all types of numbers
- Quick calculation
- High precision (no rounding, E notation,...)
- Highlight the loop section for special cases when converting to binary. Learn [more](https://github.com/NguyenASang/Decimal-Binary_Converter/wiki#what-is-the-part-that-loops-forever-when-converting-decimal-to-binary-)
- Automatically remove unnecessary parts in output and input (EG: 0001.100 -> 1.1)
- Bypass the character limit when you type input. Learn [more](https://github.com/NguyenASang/Decimal-Binary_Converter/wiki#what-is-the-input-limit-in-free-pascals-console-)

## Usage
### Normal user
You can download latest version [here](https://github.com/NguyenASang/Decimal-Binary_Converter/releases)

Known issue:
- Honestly, I don't know why the browser thinks the exe file is unsafe. When you run the .pas file with FPC (Free Pascal) it will generate an exe file and I use that exe file to upload.

### Developer
- Download and install [Free Pascal (FPC)](https://www.freepascal.org/download.html)
- Clone this repo 
```sh
git clone https://github.com/NguyenASang/Decimal-Binary_Converter.git
```
- Run FPC and open the .pas files you cloned
