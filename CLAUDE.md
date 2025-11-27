# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TypeFree is a macOS application for audio transcription with AI enhancement capabilities. It supports multiple transcription engines (local Parakeet models, native Apple transcription, and cloud-based services), AI-powered text enhancement, and context-aware "Power Mode" configurations.

## Build System and Development Commands

### Building and Running
- Open `TypeFree.xcodeproj` in Xcode
- Build and run using standard Xcode shortcuts (Cmd+R to run)
- Target platform: macOS 15.0+ (deployment target)
- Development language: Swift 5.0

### Build Configurations
- **Debug**: Includes debug logging, in-memory storage fallbacks, `ENABLE_NATIVE_SPEECH_ANALYZER` flag
- **Release**: Optimized build with dead code stripping
- Both configurations enable hardened runtime and app sandboxing

### Key Build Settings
- App bundle identifier: `dev.zhangyu.typefree`
- Development team: SRD476XUQA
- Automatic code signing enabled
- SwiftData storage location: `~/Library/Application Support/dev.zhangyu.TypeFree/`

## Architecture Overview

### Core Application Structure
The app follows a SwiftUI + SwiftData architecture with the following key components:

#### Main App Structure (`TypeFree.swift`)
- **Entry point**: `TypeFreeApp` main struct with SwiftUI App protocol
- **Data persistence**: SwiftData with `Transcription` model, multiple fallback strategies
- **Service coordination**: Manages all core services through `@StateObject` properties
- **Window management**: Main window + menu bar extra + onboarding window

#### Key Services
- **WhisperState**: Central transcription state management
- **HotkeyManager**: Global keyboard shortcut handling
- **MenuBarManager**: Menu bar UI and state
- **AIService**: AI model integration and management
- **AIEnhancementService**: Text enhancement using AI
- **ActiveWindowService**: Context-aware window detection
- **AudioCleanupManager**: Automatic audio file management
- **TranscriptionAutoCleanupService**: Automatic transcript deletion (privacy-focused)

#### Transcription Services (`Services/`)
- **ParakeetTranscriptionService**: Local Parakeet ASR models (FluidAudio framework)
- **NativeAppleTranscriptionService**: Built-in macOS Speech framework
- **CloudTranscriptionService**: OpenAI-compatible API integration
- **AudioFileTranscriptionService**: Batch processing for audio files
- **SelectedTextService**: Text selection enhancement

#### Power Mode System (`PowerMode/`)
Context-aware configurations that automatically adapt based on:
- Active application (AppConfig)
- Website/URL patterns (URLConfig)
- Custom AI prompts and models
- Screen capture integration
- Emoji-based visual indicators

#### UI Architecture (`Views/`)
- **ContentView**: Main tabbed interface with navigation
- **Onboarding**: First-time user experience and model download
- **Recorder components**: Real-time audio visualization and recording
- **Settings**: Comprehensive preference management
- **Model management**: AI model configuration and download

### Data Models (`Models/`)
- **Transcription**: SwiftData model for transcription metadata and results
- **TranscriptionModel**: Protocol for transcription engines
- **ParakeetModel**: Local model configuration
- **CustomPrompt**: User-defined AI prompts
- **PowerModeConfig**: Context-aware configuration settings

### External Dependencies
Swift Package Manager dependencies:
- **FluidAudio**: Parakeet ASR models integration
- **KeyboardShortcuts**: Global hotkey management
- **LaunchAtLogin-Modern**: Login item management
- **SelectedTextKit**: Text selection utilities
- **Zip**: Archive handling
- **swift-atomics**: Low-level atomic operations
- **mediaremote-adapter**: Media playback control

### Key Features Implementation

#### Audio Processing
- Real-time audio recording with visualization
- Voice Activity Detection (VAD) for efficient processing
- Multiple audio format support (WAV, MP3, M4A, etc.)
- Audio device management and selection

#### Privacy and Data Management
- Zero data retention philosophy with auto-cleanup
- Local-first approach with optional cloud services
- Automatic audio file deletion after processing
- User-controlled transcript retention

#### Power Mode System
The Power Mode feature allows automatic configuration switching based on:
- Active application (e.g., Notes, Safari, Slack)
- Current website URL patterns
- Custom AI prompts for different contexts
- Automatic emoji and setting changes

#### AI Enhancement
- Multiple AI provider support (OpenAI, Claude, local models)
- Custom prompt templates and management
- Context-aware enhancement based on Power Mode
- Real-time and batch enhancement processing

### Development Notes

#### Debugging
- SwiftData storage location printed in debug builds
- Debug window available with menu bar toggle option
- Comprehensive logging with OSLog framework
- Model container initialization has multiple fallback strategies

#### Localization
- Uses Swift String Catalogs (`.xcstrings`)
- Supports English and Simplified Chinese
- Localized strings for UI components

#### File Organization
- Main app code in `TypeFree/` directory
- SwiftUI views organized by feature in `Views/` subdirectories
- Services separated by functionality in `Services/`
- Power Mode system has dedicated directory for its components

#### Security and Permissions
- App sandboxing enabled with necessary entitlements
- Microphone access for audio recording
- Screen recording permission for context awareness
- Apple Events automation for browser interaction
- Hardened runtime enabled for release builds

This codebase demonstrates modern macOS app development with SwiftUI, SwiftData, and a focus on privacy while maintaining advanced AI integration capabilities.