*(draft - not applicable yet)*

# setup:
1. download dramaqueen.exe
2. copy it to your campaign folder
3, launch dramaqueen.exe
4. allow internet access if you have a firewall, it will connect to this github repository and download templates and fonts to a sub-folder called res, if they don't exist already

# usage:
1. in the setup tab, choose a html template from the list
2. in the setup tab, fill out the fields for the campaign
3. in the banner tab, click the white square to load a banner image, it will be written to a sub-folder called pub/images/banner.png
4. in the terms and conditions tab, select a preset suitable for the campaign, or fill out the sections and save as a new preset. Its important to save as the campaign settings will load whatever preset is currently selected
5. review the html source
6. save the campaign
7. go to a sub-folder called pub and open test_index.html in a browser
8. if the site looks good, go back to dramaqueen and select publish tab
9. review server and user settings, hit publish. It will ask for your password before uploading
10. review online site

# advanced usage:
1. putting a setup field title into a T&C article will be substituted with its value, eg: "promotion starts on [starting]" becomes "promotion starts on 24-02-2021" where the starting field is set to 24-02-2021
2. indentation of articles is via dashes at the beginning of the line of text: one-dash for clauses, two-dashes for paragraphs. You can set the html tags for each level in the lists below the article edit field, these are saved with the t&c preset
3. you can drag and drop pre-indented text from a source and dramaqueen will attempt to convert it to html correctly, however it expects certain consistencies:
* 4 spaces or one tab = tab
* leading spaces of 3 or less are trimmed
* no leading tab for article
* one leading tab for clause
* two leading tabs for paragraph
* a period after alphanumeric indentation markers, eg: A. 1. I. i.
* an asterisk followed by a space for bullet points, eg: * Sentence begins here
* no brackets, any of these won't be recognized: 1). (1). (1. [1]. 1]. [1.

4. given the above, dash indentation won't be applied; you can't mix the two styles
Eg: these won't work:
A. a section
	1. a clause
-- a paragraph

A. a section
1. a clause
* a paragraph

but any of these will:
```
A. a section
	1. a clause
		* a paragraph
```
```
a section
- a clause
-- a paragraph
```
```
a section
	- a clause
		-- a paragraph
```

5. to use a different font, replace the fonts in subfolder pub/fonts with the new font, but using the same names: font.ttf font.wotf
6. to use a background image, copy it to pub/images/bg.png
7. to skip the survey, just leave its field blank in setup
8. to skip the banner, just leave its field blank in banner
9. to duplicate a campaign, just copy and rename its directory, launch dramaqueen in that new directory

other notes
1. this tool is designed to work in an encapsulated way; everything for a campaign in its own folder. It can't be used to manage multiple campaigns. Keeping everything encapsulated ensures nothing is lost/broken if the campaign is copied to a different computer or restored from backups.
2. as of writing, not everything is foolproofed, especially on Linux where the UI (GTK) integration is still unfinished, eg: you can cause an error by loading a non-image into the banner image, or by resizing the UI below a certain point
3. upload is via rebol in the res sub-folder. Rebol is a stable and reliable scripting language that's being used temporarily while we wait for Red ports

