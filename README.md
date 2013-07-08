AutoLocale
==

A tiny gem for Ruby on Rails locales.
Compares two translation locales and checks for missing translations or mismatching value types.

You can also find this gem at https://rubygems.org/gems/AutoLocale

Usage
--
```
require 'autolocale'
AutoLocale.compare "path/to/complete_locale.yml", "path/to/incomplete_locale.yml"
```
'compare' will just show problems, but not affect the actual files.

```
require 'autolocale'
AutoLocale.automerge "path/to/complete_locale.yml", "path/to/incomplete_locale.yml"
```
'automerge' will automatically add not existing keys (and their values) to the incomplete locale file.
This will not touch value type mismatches.

```
require 'autolocale'
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