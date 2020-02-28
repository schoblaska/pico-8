Messing around with the [PICO-8](http://pico-8.com).

## Games
<table>
  <tr>
    <td valign="top">
      <a href="https://joeyschoblaska.github.io/pico-8/raycaster.html">
        <img src="https://raw.githubusercontent.com/joeyschoblaska/pico-8/master/carts/raycaster.p8.png" align="right">
      </a>
      <h3>Raycaster</h3>
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
Create a link in PICO-8's cart directory to the carts in this project:

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
