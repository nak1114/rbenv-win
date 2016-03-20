# rbenv for Windows

The rbenv is a great tool. I am porting this tool to Windows. 
Some of the command is not implemented, but would not be a problem in basic use.

## Usage

Show all implement commands.
````
> rbenv commands
```

How to use the detailed command, please refer to the [original rbenv](https://github.com/rbenv/rbenv).


## Installation

Install `rbenv for windows` to your `USERPROFILE` directory.
Batch file is [here](https://gist.github.com/7ea63204203883c5884d.git).

Clone git repositry
````
> git clone https://github.com/nak1114/rbenv-win.git %USERPROFILE%\.rbenv-win
````

Config path
Add the `bin` & `shims` directory to your `PATH` enviroment variable for access to the rbenv command
````
> for /f "skip=2 delims=" %a in ('reg query HKCU\Environment /v Path') do set orgpath=%a
> setx Path "%USERPROFILE%\.rbenv-win\bin;%USERPROFILE%\.rbenv-win\shims;%orgpath:~22%"
````

Restart your shell
````
> exit
````

Run the following command after `rbenv` installation , to enable the `ruby`.
````
> rbenv install 2.2.4
> rbenv global 2.2.4
> rbenv rehash
```

## License

The scripts is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Development

Not avalable any test case.
Because I don't know how to test a windows batch file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nak1114/rbenv-win. 
This project is intended to be a safe, welcoming space for collaboration, 
and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
