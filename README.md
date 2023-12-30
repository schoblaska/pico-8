Messing around with the [PICO-8](http://pico-8.com).

## Games
<table>
  <tr>
    <td valign="top" width="999">
      <a href="https://schoblaska.github.io/pico-8/tvstatic.html">
        <img src="https://raw.githubusercontent.com/schoblaska/pico-8/master/carts/tvstatic.p8.png" align="right">
      </a>
      <h3>TV Static</h3>
      <p>Experimenting with a TV static effect.
    </td>
  </tr>
  <tr>
    <td valign="top">
      <a href="https://schoblaska.github.io/pico-8/sokotiles_wip2.html">
        <img src="https://raw.githubusercontent.com/schoblaska/pico-8/master/carts/sokotiles_wip2.p8.png" align="right">
      </a>
      <h3>Sokotiles (wip2)</h3>
      <p>A sliding tile game inspired by <a href="https://www.sokobanonline.com/">Sokoban</a> and <a href="https://www.dosgamesarchive.com/download/cyberbox">Cyberbox</a></p>.
    </td>
  </tr>
  <tr>
    <td valign="top">
      <a href="https://schoblaska.github.io/pico-8/hund3d.html">
        <img src="https://raw.githubusercontent.com/schoblaska/pico-8/master/carts/hund3d.p8.png" align="right">
      </a>
      <h3>Hundstein 3D</h3>
      <p>An experiment using raycasting to create a Wolfenstein 3D like engine in PICO-8.</p>
      <ul>
        <li><a href="https://lodev.org/cgtutor/raycasting.html">Lode's Computer Graphics Tutorial: Raycasting</a></li>
      </ul>
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
  * (Note that [`tline()`](https://pico-8.fandom.com/wiki/Tline) was introduced to PICO-8 after this article was written and may make some parts easier to implement.)
* [LOSPEC](https://lospec.com/): Pixel art palettes, tutorials, and assets
