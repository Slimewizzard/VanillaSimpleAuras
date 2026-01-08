# VanillaSimpleAuras

A simple, lightweight, and customizable aura and consumable tracker for World of Warcraft (Vanilla / 1.12.1).

## Features

### 1. Custom Aura Tracking
Track any spell cooldown or player buff by name and icon.
- **Easy Configuration**: Add spells/buffs directly via the in-game UI.
- **Stack Counts**: Automatically displays stack counts for buffs.
- **Cooldowns**: Shows cooldown duration numbers on icons.

### 2. Smart Consumable Tracker
Never forget your world buffs or raids consumes again.
- **Extensive Database**: Pre-configured list of common Vanilla consumables (Flasks, Elixirs, Food, Weapon Oils, Juju, etc.).
- **Missing Buff Detection**: Icons appear automatically when you are missing a buff you selected to track.
- **Expiration Warning**: Icons reappear with a **Red 'X'** overlay when your buff is about to expire (configurable time threshold).
- **Click-to-Buff**: **Clicking the consumable icon** will automatically find the item in your bags and use it!
  - Smartly handles Weapon Enchants (Oils/Stones) for Main Hand vs Off Hand.

### 3. Customizable UI
- **Movable Frames**: Unlock frames to drag them anywhere on your screen.
- **Minimap Button**: Quick access to the configuration menu.
- **Performance Tuning**: Adjust update intervals to balance between responsiveness and CPU usage.
  - **Update Speed**: Control how fast custom auras update.
  - **Check Speed**: Control how often bag/consume checks happen (save FPS!).
- **Warning Threshold**: Slider to set how many seconds remaining trigger the "Expiring" warning (Default: 2 minutes).

## Usage

1. **Open Config**: Type `/vsa` or click the minimap button.
2. **Add Custom Auras**:
   - Enter the **Name** (exact name of spell/buff).
   - Enter the **Icon Name** (e.g., `Spell_Holy_FlashHeal`). You can find these on Wowhead or database sites.
   - Click "Add".
3. **Track Consumables**:
   - Click "Consume List" in the options.
   - Select categories (Elixirs, Food, etc.).
   - Check the boxes for items you want to maintain.
   - Icons will appear if you are missing the buff or if it's running out.
4. **Unlock/Move**:
   - Toggle "Unlock Frame" in the options to see and move the anchor frames.

## Installation

1. Copy the `VanillaSimpleAuras` folder into your `Interface\AddOns\` directory.
2. Launch the game.

## Slash Commands

- `/vsa` - Open the configuration window.
- `/vanillasimpleauras` - Alternative command.
