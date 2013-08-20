AutoLocaleQuotes
==

Fork from https://github.com/nedec/autolocale_gem<br>
Modificated to wrap every value with qutoes.


A tiny gem for Ruby on Rails locales.
Compares two translation locales and checks for missing translations or mismatching value types.

You can also find this gem at https://rubygems.org/gems/AutoLocale

Usage
--

You can run this in `irb`
```
require 'autolocalequotes'
AutoLocale.compare "path/to/complete_locale.yml", "path/to/incomplete_locale.yml"
```
'compare' will just show problems, but not affect the actual files.

```
require 'autolocalequotes'
AutoLocale.automerge "path/to/complete_locale.yml", "path/to/incomplete_locale.yml"
```
'automerge' will automatically add not existing keys (and their values) to the incomplete locale file.
This will not touch value type mismatches.

```
require 'autolocalequotes'
AutoLocale.untranslated "path/to/complete_locale.yml", "path/to/incomplete_locale.yml"
```
Use 'untranslated' when there are no issues and you want to find untranslated (but existing) keys.<br>
In fact, this will notify you when two values are the same.

Example
--
`AutoLocale.compare "example_files/en_complete.yml", "example_files/en_incomplete.yml"`
![Preview](http://i.imgur.com/wYMW9RH.png)

``AutoLocale.automerge "example_files/en_complete.yml", "example_files/en_incomplete.yml"``
![Preview](http://i.imgur.com/3Aicwdu.png)<br/>
As mentioned above, it will not touch value type mismatches - but it shows them to you so it can be fixed by hand.

`AutoLocale.untranslated "example_files/en_complete.yml", "example_files/en_incomplete.yml"`
![Preview](http://i.imgur.com/SdOGiZe.png)

Shortcut for all locale files
--
Put this line of code into file.rb and call it with `ruby file.rb` from your locales path:<br>
`require 'autolocalequotes';Dir.glob('*.yml').permutation(2).to_a.each{|f|print "#{f[0]} <=> #{f[1]}: ";AutoLocale.compare(f[0].to_s, f[1].to_s)}`<br>
It will compare every file with all the other files in the directory.<br/>
Change `compare` to one of the methods listed above, if you want to.
