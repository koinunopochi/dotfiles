@AGENTS.md

## Claude Code only

### Push Policy
- このリポへの `git push` は、必ずユーザーに最終確認してから実行する
- 勝手に push しない
- 公開リポなので、コミット内容も commit 直前に diff を見せて確認を取る

### 設計判断の優先順位
1. vim 起動が爆速であること
2. 薄く小さく保つ
3. Stow + Nix + direnv の構造を崩さない
