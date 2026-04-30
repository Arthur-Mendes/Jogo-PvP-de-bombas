-- jogo infinito
-- comandos do ADM
local hitbox = false
-- inimigo
local slimeSpriteSheet
local Squadro = {}
local slimes = {}
local slime = {
  x = 100 ,
  y = 100 ,
  frame = 1,
  vel = 60,
  animTimer = 0,
  modo = "sheetPose",
  hit = false,
  dead = false,
deathTimer = 0,
deathSpeed = 1,
  hp = 3,
  hitTimer = 0,
  hitDuracao = 0.3,
  -- hit box 
  w = 40,
  h = 40,
  -- cor,
  r = 1,
  g = 1,
  b = 1,
  alpha = 1
}
local dificuldade = 3 
local Sdireita = true
local slimeBox = {
  x = slime.x - slime.w/2,
  y = slime.y - slime.h/2,
  w = slime.w,
  h = slime.h
}
-- player
local mapachao = nil
local playerSpriteSheet
local Pquadro = {}
local frameW = 32
local frameH = 32
local Pframe = 1
local animTimer = 0
local olhandoDireita = true
local player = {
x = 0,
y = 0,
vel = 200,
spawn = false,
-- hitbox
w = 18,
h = 30,
hitCooldown = 0
}
local playerHitbox = {
  x = 0,
  y = 0,
  w = 0,
  h = 0
}
local camera = {
  x = 0,
  y = 0
}
local arma = {
  angulo = 0,
  sprite = nil,
  lado = 15
}
local cogumelo = {}
local cogPframe = 1
local cenas = "inicio"
local musicas = {
inicio = nil
}
local dx = 0
local botao = {
  A = {},
  }
  local animBotao = {
  timer = 0,
  sprite = 1,
  tamanho = 0.5
  }
local dy = 0
local fonte = nil
local titulo = {
tempo = 0,
escala = 1,
texto = "Dreamer mushroom",
largura = 0
}
local esporos = {}
local start = {
  texto = "pressione START para iniciar",
  escala = 1,
  alpha = 1,
  largura = 0,
  tempo = 0,
  R = 1,
  G = 1,
  B = 1
  }
local transicao = {
  ativa = false,
  alpha = 0,
  modo = "out" --o out ou in 
  }
local sons  = {
  start = nil
}
local mapa = {
  {1,1,1,1,1},
  {1,0,0,0,1},
  {1,0,0,0,1},
  {1,0,0,0,1},
  {1,1,1,1,1}
  }
  local mensagem = ""
  -- colisao player
local function colisaoPlayer()
    playerHitbox.x = player.x + 4
    playerHitbox.y = player.y -1
    playerHitbox.w = 18
    playerHitbox.h = 40
  end
  -- colisão
local function colisao(a, b)
  local ax = a.x - (a.w/2)
  local ay = a.y - (a.h/2)
  local bx = b.x - (b.w/2)
  local by = b.y - (b.h/2)

  return ax < bx + b.w and
         ax + a.w > bx and
         ay < by + b.h and
         ay + a.h > by
end
  -- inimigo slime função
local function perseguirPlayer(dt)
  if slime.hit then
    slime.vel = 40
  elseif slime.hit == false then
    slime.vel = 60
    end
  local dx = player.x - slime.x
  local margemplayer = 2

  if player.spawn then  
if dx > 0 then
  Sdireita = false
elseif dx < 0 then
  Sdireita = true
end
    slime.modo = "perseguirPlayer"
    -- eixo X
    if slime.x < player.x - margemplayer then
      slime.x = slime.x + slime.vel * dt
    elseif slime.x > player.x + margemplayer then
      slime.x = slime.x - slime.vel * dt
    end
    
    -- eixo Y
    if slime.y < player.y - margemplayer then
      slime.y = slime.y + slime.vel * dt
    elseif slime.y > player.y + margemplayer then
      slime.y = slime.y - slime.vel * dt
    end
  end
end
local function animacaoInimigo(dt)
  slime.animTimer = slime.animTimer + dt

    if slime.hit then
      if Sdireita == false then
        slime.frame = 7
        else 
          slime.frame = 8
      end
      return
    end
  if slime.animTimer > 0.2 then 
    slime.animTimer = 0
    
    if slime.modo == "perseguirPlayer" then
    if Sdireita == false then
      -- frames 1 a 3
      slime.frame = slime.frame + 1
      if slime.frame > 3 then
        slime.frame = 1
      end

    else
      -- frames 4 a 6
      slime.frame = slime.frame + 1
      if slime.frame > 6 or slime.frame < 4 then
        slime.frame = 4
      end
    end
    end
  end
  end
local function slimeHit(dano)
  if slime.dead then return end
  if slime.hitTimer > 0 then return end

  slime.hp = slime.hp - dano
  slime.hit = true
  slime.hitTimer = slime.hitDuracao

  if slime.hp <= 0 then
    slime.dead = true
    slime.modo = "morto"
  end
end
local function atualizarMorteSlime(dt)
  if not slime.dead then return end

  -- para de perseguir / mover
  slime.vel = 0

  -- animação de morte (exemplo: frame 9 ou 10)
  if Sdireita then
  slime.frame = 10
  else
    slime.frame = 9
    end

  -- fade out
  slime.alpha = slime.alpha - dt * slime.deathSpeed
  slime.alpha = math.max(0, slime.alpha)

  -- leve “afundar”
  slime.y = slime.y + 20 * dt

  -- remove quando sumir
  if slime.alpha <= 0 then
    slime.modo = "kill"
  end
end
local function slimeMorte()
  if slime.hp <= 0 then
    mensagem = "morreu"
  end
end
-- player funções
local function playerHit(dano)
  if player.hitCooldown > 0 then return end
  
  player.hitCooldown = 0.5 -- meio segundo de invencibilidade
  mensagem = "DANO!"
end


  local armaX = 0
  local armaY = 0
local tiroCooldown = 0
local esporoSprite 
local tiros = {}
  local abc = 0
  local function atirarEsporo()
    local speed = 250
    -- posicao da arma
  local dirX = math.cos(arma.angulo - math.pi / 2)
  local dirY = math.sin(arma.angulo - math.pi / 2)
  table.insert(tiros,{
    x = armaX,
    y = armaY,
    vx = dirX * speed,
    vy = dirY * speed,
    vida = 2,
    angulo = math.atan2(dirY,dirX) + math.pi /2,
    
    -- HITBOX
    w = 20,
    h = 20
    })
  end
  
function love.load()
  -- ===== fontes =====
fonte = love.graphics.newFont(
"fonts/daydream.otf", 24)


dx = love.graphics.getWidth() / 2
dy = love.graphics.getHeight() / 2
player.x = 0
player.y = 0
-- ===== MAPA =====
mapachao = love.graphics.newImage("Dreamer Mushroom/imagens/Mapa/mapa.png")
-- ===== BOTÕES =====
botao.A[1] = love.graphics.newImage(
  "Dreamer Mushroom/imagens/botãoA1.png")
botao.A[2] = love.graphics.newImage(
  "Dreamer Mushroom/imagens/botãoA2.png")
-- ===== cogumelo =====
for i = 1,5 do
  table.insert(
    cogumelo,
    love.graphics.newImage(
      "Dreamer Mushroom/imagens/cogumelo_"..i..".png"))
end
-- ===== PLAYER =====

love.graphics.setDefaultFilter(
  "nearest", "nearest")
-- arma 
arma.sprite = love.graphics.newImage(
  "Dreamer Mushroom/imagens/Arma/cajadoFungico.png")
-- inimigo slime 
slimeSpriteSheet = love.graphics.newImage(
  "Dreamer Mushroom/imagens/inimigos/slime.png")
local slimeColunas = 5
for i = 0, 9 do
  local x = (i % slimeColunas) * frameW
  local y = math.floor(i/slimeColunas) * frameH
  
  Squadro[i+1] = love.graphics.newQuad(
    x,y,
    frameW,frameH,
    slimeSpriteSheet:getDimensions()
    )
end
-- player 
local playerColunas = 4
playerSpriteSheet = love.graphics.newImage(
  "Dreamer Mushroom/imagens/Player/player1_1.png")
for i = 0, 7 do
  local x = (i % playerColunas) * frameW
  local y = math.floor(i/playerColunas) * frameH
  
  Pquadro[i+1] = love.graphics.newQuad(
    x,y,
    frameW,frameH,
    playerSpriteSheet:getDimensions()
    )
end
-- bala
esporoSprite = love.graphics.newImage("Dreamer Mushroom/imagens/Arma/esporo.png")
  

-- ===== ESPOROS =====
for i = 1,100 do
table.insert(esporos,{
x = math.random(0, love.graphics.getWidth()),
y = math.random(0, love.graphics.getHeight()),
speed = math.random(10,40),
tamanho = math.random(1,3)
})
end
-- ===== MUSICAS =====
musicas.inicio= love.audio.newSource(
"Dreamer Mushroom/Sons/Musicas/DM_inicioMusic.ogg", "stream")
musicas.inicio:setLooping(true)

-- ===== efeitos sonoros 
sons.start = love.audio.newSource(
  "Dreamer Mushroom/Sons/Efeitos sonoros/play.ogg","static")
end

function love.update(dt)
-- ===== ESPOROS =====
local mx = 0
local my = 0
local mx2 = 0
local my2 = 0
if cenas == "inicio" then
for _, e in ipairs(esporos) do
e.y = e.y - e.speed * dt

if e.y < 0 then  
  e.y = love.graphics.getHeight()  
  e.x = math.random(0, love.graphics.getWidth())  
  end
end
-- ===== TITULO ===== 
titulo.tempo = titulo.tempo + dt
titulo.escala = 1 + math.sin(titulo.tempo * 2) * 0.1
-- ===== START =====
start.tempo = start.tempo + dt
start.escala = 0.5 + math.sin(start.tempo * 2) * 0.1
if not musicas.inicio:isPlaying() then
  musicas.inicio:play()
  end
elseif cenas ~= "inicio" then
  if musicas.inicio:isPlaying() then
    musicas.inicio:stop()
  end
end
if cenas == "jogo" then
camera.x = player.x - love.graphics.getWidth() / 2
camera.y = player.y - love.graphics.getHeight() / 2

  animBotao.timer = animBotao.timer + dt
  if animBotao.timer >= 0.5 then
    animBotao.timer = animBotao.timer - 0.5
    animBotao.sprite = 3 - animBotao.sprite
  end
  
tiroCooldown = math.max(0,tiroCooldown - dt)

  local joystick = love.joystick.getJoysticks()[1]
  -- joystick
  if joystick and player.spawn then
    mx2 = joystick:getGamepadAxis("rightx")
    my2 = joystick:getGamepadAxis("righty")
    -- dead zone
local deadzone = 0.2
local magnitude = math.sqrt(mx2*mx2 + my2*my2)

if magnitude > deadzone then
   arma.angulo = math.atan2(my2, mx2) + math.pi/2

    if tiroCooldown <= 0 then
      atirarEsporo()
      tiroCooldown = 0.30
    end
end
end
    
    
    
  if joystick and player.spawn then
    mx = joystick:getGamepadAxis("leftx")
    my = joystick:getGamepadAxis("lefty")
    
    -- DEAD ZONE
    if math.abs(mx) < 0.2 then mx = 0 end
    if math.abs(my) < 0.2 then my = 0 end
    
    player.x = player.x + mx * player.vel * dt
    player.y = player.y + my * player.vel * dt
  end
  -- =========== PLAYER MOVE ==========
  animTimer = animTimer + dt
  local moving = (mx ~= 0 or my ~= 0)
  
-- direção
if mx < 0 then
  olhandoDireita = false
elseif mx > 0 then
  olhandoDireita = true
end
if moving then
  if olhandoDireita and (Pframe < 7 or Pframe > 8) then
    Pframe = 7
  elseif not olhandoDireita and (Pframe < 5 or Pframe > 6) then
    Pframe = 5
  end
end

if moving then 
  -- andando
  if animTimer > 0.2 then
    animTimer = 0
    
    if olhandoDireita then
      -- Pframes 7-8
      if Pframe == 7 then Pframe = 8 else Pframe= 7
      end else
      -- Pframes 5-6
      if Pframe == 5 then Pframe = 6 else Pframe=5 end
    end
  end
  else
    -- parado 
    if animTimer > 0.4 then
      animTimer = 0
      
      if olhandoDireita then
        -- Pframes 3-4
        if Pframe == 3 then Pframe = 4 else Pframe = 3
        end else 
        -- Pframes 1-2
        if Pframe == 1 then Pframe = 2 else Pframe = 1 end
      end
    end
end
slimeBox.x = slime.x - slime.w / 2
slimeBox.y = slime.y - slime.h / 2
slimeBox.w = slime.w
slimeBox.h = slime.h

for i = #tiros, 1, -1 do
    local t = tiros[i]

    t.x = t.x + t.vx * dt
    t.y = t.y + t.vy * dt
    t.angulo = t.angulo + dt * 10
    abc = t.angulo
    t.vida = t.vida - dt
    
    -- colisao com o slime
    if not slime.dead and colisao(t,slimeBox) then
      slimeHit(1)
        table.remove(tiros, i)
        else
          if t.vida <= 0 then
        table.remove(tiros, i)
          end
    end
end
-- INIMIGO
if slime.hit then
  slime.hitTimer = slime.hitTimer - dt
  
  if slime.hitTimer <= 0 then
    slime.hit = false
  end
end
if slime.dead then
  atualizarMorteSlime(dt)
else
  perseguirPlayer(dt)
  animacaoInimigo(dt)
end
if slime.hit then
  slime.r = 1
  slime.g = 0.3
  slime.b = 0.3
else
  slime.r = 1
  slime.g = 1
  slime.b = 1
end
if slime.modo == "kill" then
  slime.x = -9999
  slime.y = -9999
end
-- player colisão
if player.spawn then
  colisaoPlayer()
  if not slime.dead and colisao(playerHitbox,slime) then
    playerHit(1)
  end
end
player.hitCooldown = math.max(0, player.hitCooldown - dt)
end
-- END CENA JOGO =====
-- ===== TRANSIÇÃO =====
if transicao.ativa then
  local velocidade = 1.5
  
  if transicao.modo == "out" then
    -- escurecer
    transicao.alpha = transicao.alpha + dt * velocidade
    transicao.alpha = math.min(1,transicao.alpha)
    
    -- fade da musica
  musicas.inicio:setVolume(math.max(0, 1 - transicao.alpha))
  -- cor do start 
  start.R = start.R - dt 
  start.G = start.G - dt 
  start.B = start.B - dt 
  start.R = math.max(0.55, start.R)
  start.G = math.max(0.55, start.G)
  start.B = math.max(0.55, start.B)
  
  if transicao.alpha >= 1 then
    transicao.alpha = 1
    musicas.inicio:stop()
    cenas = "jogo"
    transicao.modo = "in"
  end
  
  elseif transicao.modo == "in" then
    -- clareando
    transicao.alpha = transicao.alpha - dt * velocidade
    transicao.alpha = math.max(0,transicao.alpha)
    
    if transicao.alpha <= 0 then
      transicao.ativa = false
    end
  end
end

end



function love.gamepadpressed(joystick,button)
  if button == "start" and cenas == "inicio" then
    if not sons.start:isPlaying() then
      sons.start:play()
    end
    transicao.ativa = true
    transicao.modo = "out"
  end
    if button == "a" and cenas == "jogo" then
      cogPframe = cogPframe + 1
    if  cogPframe == 4 then
      player.spawn = true
    end
    end
    if button == "b" then
  hitbox = not hitbox
end
end


function love.draw()
-- ===== ESPOROS =====
if cenas == "inicio" then
love.graphics.setColor(0.7, 0.3, 1, 0.6)
for _, e in ipairs(esporos) do
love.graphics.circle("fill",e.x,e.y,e.tamanho)
end
love.graphics.setColor(1,1,1,1)
love.graphics.setFont(fonte)

love.graphics.push()

love.graphics.translate(dx, 30)
love.graphics.scale(titulo.escala, titulo.escala)

titulo.largura = fonte:getWidth(titulo.texto)
love.graphics.print(titulo.texto, -titulo.largura/2, 0)

love.graphics.pop()
-- ===== START =====
love.graphics.push()

love.graphics.setColor(start.R,start.G,start.B)

love.graphics.translate(dx, dy)
love.graphics.scale(start.escala, start.escala)

start.largura = fonte:getWidth(start.texto)
love.graphics.print(start.texto, -start.largura/2, 0)

love.graphics.pop()

elseif cenas == "jogo" then
love.graphics.setColor(1,1,1,1)
love.graphics.push()

love.graphics.translate(-camera.x, -camera.y)

local spriteAtualp1 = botao.A[animBotao.sprite]
love.graphics.draw(
  mapachao,
  0,
  0,
  0,
  1,1,
  mapachao:getWidth()/2,
  mapachao:getHeight()/2
  )
if spriteAtualp1 then
    love.graphics.draw(
    spriteAtualp1,
    0,
    0 + 100,
    0,
    0.25,0.25,
    spriteAtualp1:getWidth()/2,
    spriteAtualp1:getHeight()/2
    )
end
--player
local maoOffsetX = 10   -- ajuste fino
local maoOffsetY = 5    -- ajuste fino

local dir = olhandoDireita and 1.3 or -1

armaX = player.x + maoOffsetX * dir * 2
armaY = player.y + maoOffsetY
if player.spawn then
love.graphics.draw(
  playerSpriteSheet,
  Pquadro[Pframe],
  player.x,
  player.y,
  0,
  3,3,
  frameW /2,
  frameH /2
  )
  
  
  love.graphics.draw(
  arma.sprite,
  armaX,
  armaY + 5,
  arma.angulo,
  1,1,
  arma.sprite:getWidth()/2,
  arma.sprite:getHeight()/2
)
for _, t in ipairs(tiros) do
  love.graphics.draw(
    esporoSprite,
    t.x,
    t.y,
    t.angulo,
    1,1,
    esporoSprite:getWidth()/2,
    esporoSprite:getHeight()/2
  )
end
love.graphics.setColor(
slime.r,slime.g,slime.b,slime.alpha)
love.graphics.draw(
  slimeSpriteSheet,
  Squadro[slime.frame],
  slime.x,
  slime.y,
  0,
  3,3,
  frameW /2,
  frameH /2
  )
  love.graphics.setColor(1,1,1,1)
  -- ===== HITBOX =====
  if hitbox == true then 
  love.graphics.setColor(1,0,0,1)
    love.graphics.rectangle(
      "line",
      slime.x - slime.w / 2,
      slime.y - slime.h / 2,
      slime.w,
      slime.h
      )
    for _, t in ipairs(tiros) do
  love.graphics.rectangle(
    "line",
    t.x - t.w / 2,
    t.y - t.h / 2,
    t.w,
    t.h)
    end
  love.graphics.setColor(0,1,0,1)
love.graphics.rectangle(
  "line",
  playerHitbox.x - playerHitbox.w / 2,
  playerHitbox.y - playerHitbox.h / 2,
  playerHitbox.w,
  playerHitbox.h
)
love.graphics.circle("fill", player.x, player.y, 3)
end

  love.graphics.setColor(1,0,0,1)
love.graphics.rectangle(
  "fill",
  slime.x - slime.w / 2,
  slime.y + 30,
  slime.hp * 10,
  5)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(mensagem,player.x,player.y - 100)
elseif player.spawn == false then
love.graphics.draw(
  cogumelo[cogPframe],
  0,
  0 - 100,
  0,
  1,1,
  cogumelo[cogPframe]:getWidth() / 2,
  cogumelo[cogPframe]:getHeight() / 2
  )
  
end
love.graphics.pop()
end
-- ===== TRANSIÇÃO =====
if transicao.alpha > 0 then
  love.graphics.setColor(0,0,0,transicao.alpha)
  love.graphics.rectangle(
    "fill",
    0,
    0,
    love.graphics.getWidth(),
    love.graphics.getHeight()
  )
  love.graphics.setColor(1,1,1,1)
end

end