# 🏓 Ping Pong Game in x86 Assembly

A classic Ping Pong (Pong) game implemented in **x86 Assembly Language** for DOS environments. The game demonstrates low-level programming concepts including interrupt handling, direct video memory access, keyboard input processing, and real-time game mechanics.

## Features

- 🎮 Real-time Ping Pong gameplay
- ⌨️ Keyboard-controlled paddles
- ⚡ Timer interrupt-based ball movement
- 🖥️ Direct video memory manipulation (0xB800)
- 📊 Score tracking system
- 🔄 Ball collision and bouncing mechanics
- 🛠 Custom keyboard and timer ISR implementation
- 🎯 Winning condition when a player reaches 5 points

## Controls

| Key | Action |
|------|---------|
| ← | Move active paddle left |
| → | Move active paddle right |

## Technical Concepts Used

- x86 Assembly Programming
- DOS COM Executable Format
- Interrupt Service Routines (ISR)
- Keyboard Interrupt (INT 09h)
- Timer Interrupt (INT 08h)
- Direct Screen Buffer Access
- Real-Time Game Loop
- Memory Management
- Low-Level Hardware Interaction

## Game Logic

- Two paddles are placed at the top and bottom of the screen.
- The ball moves diagonally across the screen.
- Players must prevent the ball from passing their paddle.
- Missing the ball awards a point to the opponent.
- First player to reach **5 points wins**.

## Requirements

- DOSBox or any DOS-compatible emulator
- NASM/TASM compatible assembler

## Build & Run

### Assemble

```bash
nasm -f bin pingpong.asm -o pingpong.com
```

### Run

```bash
dosbox pingpong.com
```

## Learning Outcomes

This project is a practical demonstration of:

- Interrupt handling
- Hardware-level programming
- Game development in Assembly
- Direct memory manipulation
- Real-time event processing

## Author

Developed as a learning project to explore low-level game programming and x86 Assembly language.