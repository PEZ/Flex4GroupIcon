##A Flex 4 Group Icon Component

I needed a component that would represent a group of people. That's what this little project is about.

Basically you create an instance of GroupIcon and set its `avatars` attribute point to a collection of objects implementing the IGroupIconItem interface.
For the lazy, there's an Avatar class included that you can simply inherit to get your avatar item objects to behave as the component expects.

The component will load the avatars from the URLs or bitmaps provided with the items and render a square with 1, 2, 3 and then 2^2, 3^2, ... n^2 avatars.

###Component attributes
You can use the `maxAvatars` attribute to tell the group icon to stop before 100. There's also `mainIconURL` attribute that renders an
icon of your choice in the center of the component.

Here's an example MXML include:

`<bttc:GroupIcon id="gi6" mainIconURL="{_mainIconURL2}" maxAvatars="9" avatars="{_selectedAvatars}"
                 width="100" height="100" x="10" y="205"/>`

##Styling
The GroupIcon can have a background, a border and grid lines. The following CSS styles control them:
* `borderVisible`, Boolean, default: true
* `borderWeight`, Length, default: 1
* `borderPercentWeight`, Number 0-100, default: 0
* `borderColor`, Color, default: 0x000000
* `borderAlpha`, Number 0-1, default: 1

* `backgroundColor`, Color, default: 0xffffff
* `backgroundAlpha`, Number 0-1, default: 1

* `showGridlines`, Boolean, default: false
* `gridlinesWeight`, Length, default: 2
* `gridlinesPercentWeight`, Number 0-100, default: 0
* `gridlinesColor`, Color, default: 0x7f7f7f
* `gridlinesAlpha`, Number 0-1, default: 1

The optional "main icon" can also be styled:

* `mainIconPercentSize`, Number 0-100, default: 40
* `showMainIconBorder`, Boolean, default: false
* `mainIconBorderWeight`, Length, default: 2
* `mainIconBorderPercentWeight`, Number 0-100, default: 0
* `mainIconBorderColor`, Color, default: 0x7f7f7f
* `mainIconBorderAlpha`, Number 0-1, default: 1
* `mainIconBackgroundColor`, Color, default: 0xffffff
* `mainIconBackgroundAlpha`, Number 0-1, default: 1

All `percentWeight` attributes take precedence over any `borderWeight` dittos. Please note the daults, they can be a bit surprising. =)

For instance, to style all GroupIcon instances to have a transparent background, a 2 pixel wide, limegreen border,
show almost black gridlines and have a "main icon" with a dark, somewhat transparent background and an almost white border:
`
		@namespace bttc "com.betterthantomorrow.components.*";

		bttc|GroupIcon {
			backgroundAlpha: 0.0;
			borderVisible: true;
			borderColor: #affe7f;
			cornerRadius: 10;
			borderWeight: 2;
			showGridlines: true;
			gridlinesColor: #1c1c1c;
			mainIconPercentSize: 50;
			showMainIconBorder: true;
			mainIconBorderColor: #ececec;
			mainIconBackgroundColor: #1c1c1c;
			mainIconBackgroundAlpha: 0.85;
		}		
`

###Try it
An interactive test of the component is available here: [http://dl.dropbox.com/u/3259215/GroupIconTest/GroupIconTest.html](http://dl.dropbox.com/u/3259215/GroupIconTest/GroupIconTest.html)
(View source is enabled).

###Quick howto use this in your Flex 4 project:
Clone (or, preferably, fork-then-clone) this project and then import it into Flash Builder.
It should get imported as a Flex Library project. Then you have at least two options:

1. Add the Flex4GroupIcon library project to the Build Path of the project where you need the component.
2. Build the library project and copy the resulting swc-file out of the bin/ folder and put it in the libs/ folder of your groupicon-needing project.

Option 1 is to prefer I'd say, because then you can much easier follow what's going on in the debugger, fix bugs and such.
Option 2 assumes you have a standard setup project with a library folder called libs/ setup in your projects Build Path.

###Keep your fork in sync
If you fork this repository and still want to keep your fork in sync with any bug fixes/changes in this repo that I either make
myself or pull in from pull requests from others; This is the easiest way I have found:

1. Add this repository as a remote upstream to the clone of your fork: <br>
 `$ git remote add upstream https://PEZ@github.com/PEZ/Flex4GroupIcon.git`
2. Then fetch from upstream:<br>
 `$ git fetch upstream`
3. Whenever you want to merge in any changes in the main repo:<br>
 `$ git merge upstream/master`

That last step is assuming you want to merge the master branch of course, but that's the only branch there is yet anyway. =)
