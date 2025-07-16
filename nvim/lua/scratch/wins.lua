
_G.my_win = Snacks.win.new({
  width = 0.5,
  position = 'right',
})

_G.my_win:toggle()

_G.my_win:focus()

_G.my_win:set_title('My Snacks Window')

_G.my_win:size()

_G.my_win:update()

_G.my_win:set_buf(23)

_G.my_win:scroll(true)
