## About
A high precision decimal/binary converter written in Free Pascal

## Features
- Support negative, positive, real numbers
- Quick calculation
- High precision (no rounding, E +, E, E -, ...)
- Highlight the loop section for special cases when converting to binary. For more [information](https://github.com/NguyenASang/Decimal-Binary_Converter/wiki#what-is-the-part-that-loops-forever-when-converting-decimal-to-binary-)
- Bypass the character limit when you type input
- Automatically remove unnecessary parts in output and input (EG: 0001.100 -> 1.1)

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
