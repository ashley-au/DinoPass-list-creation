# DinoPass-list-creation
quick shell script to build a complex wordlist via the DinoPass API


Create unique passwords, features:
•  Mixed case letters
•  Numbers
•  Special characters like @, ), +
•  Append to or overwrite an existing list
•  Maintain password uniqueness
•  Show progress

Outputs to password_list.txt and can continue to append more passwords whenever needed. the script will always maintain uniqueness while adding new entries.

Runtime options:
•  ./generate_passwords.sh for 10 passwords (default)
•  ./generate_passwords.sh N where N defines the number of passwords
