Messing around with the [PICO-8](http://pico-8.com).

## Games
<table>
  <tr>
    <td valign="top">
      <a href="https://joeyschoblaska.github.io/pico-8/hundstein.html">
        <img src="https://raw.githubusercontent.com/joeyschoblaska/pico-8/master/carts/hundstein.p8.png" align="right">
      </a>
      <h3>Hundstein</h3>
      <p>An experiment using raycasting to create a Wolfenstein 3D like engine in PICO-8.</p>
      <ul>
        <li><a href="https://lodev.org/cgtutor/raycasting.html">Lode's Computer Graphics Tutorial: Raycasting</a></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td valign="top">
      <a href="https://joeyschoblaska.github.io/pico-8/lander.html">
        <img src="https://raw.githubusercontent.com/joeyschoblaska/pico-8/master/carts/lander.p8.png" align="right">
      </a>
      <h3>Lander</h3>
      Made by following one of the tutorials in <a href="https://mboffin.itch.io/gamedev-with-pico-8-issue1">Game Development in PICO-8</a> by <a href="https://mboffin.itch.io/">MBoffin</a>. Land the spaceship on the pad.
    </td>
  </tr>
</table>

## Development (OS X)
Create a link in PICO-8's cart directory to the src dir of this repo:

```
ln -s ~/projects/pico-8/src ~/Library/Application\ Support/pico-8/carts/gh
```

To build cartridges, first build the PNG (in the PNG version, the includes are flattened into one file). Then load the PNG and build the HTML and JS files from that.

```
# in PICO-8:
load gamename
save gamename.p8.png
load gamename.p8.png
export gamename.html
load gamename

# from command line:
mv src/gamename.p8.png carts/
mv src/gamename.html docs/
mv src/gamename.js docs/
```

## Resources
* [PICO-8 Cheat Sheet](https://www.lexaloffle.com/bbs/files/16585/PICO-8_Cheat-Sheet_0-9-2.png)
* [Famous characters as PICO-8 sprites](https://twitter.com/johanvinet/status/635814153601597441)
* [Food and drink sprites](https://twitter.com/JUSTIN_CYR/status/634546317713391616)
* [Curated list of resources](https://github.com/pico-8/awesome-PICO-8#resources)
* [Lode's Computer Graphics Tutorial](https://lodev.org/cgtutor/index.html)
* [PICO-8 Lighting](https://hackernoon.com/pico-8-lighting-part-1-thin-dark-line-8ea15d21fed7)
* [LOSPEC](https://lospec.com/): Pixel art palettes, tutorials, and assets
