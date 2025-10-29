# VS Code Copilot 自动审批配置

## 🎯 功能说明

Socrate 现在会自动配置 VS Code，让 GitHub Copilot 无需手动审批就能执行教学脚本！

### 什么是自动审批？

在教学流程中，Copilot 会调用 PowerShell 脚本（如 `Update-Progress.ps1`、`Copy-Chapter-Template.ps1`）。
默认情况下，每次都需要点击 "Continue" 按钮确认。

启用自动审批后，这些受信任的脚本会立即执行，让学习流程更流畅！

---

## 📋 配置内容

Socrate 会在项目的 `.vscode/settings.json` 中添加：

```json
{
    "chat.promptFilesRecommendations": {
        "socrate.outline": true,
        "socrate.prepare": true,
        "socrate.check": true,
        "socrate.practice": true,
        "socrate.lesson": true
    },
    "chat.tools.terminal.autoApprove": {
        ".specify/scripts/bash/": true,
        ".specify/scripts/powershell/": true
    }
}
```

### 配置说明

1. **`chat.promptFilesRecommendations`**: 
   - 让 Copilot 推荐 Socrate 的 5 个提示词命令
   - 在聊天界面会显示快捷建议

2. **`chat.tools.terminal.autoApprove`**:
   - 自动审批 `.specify/scripts/` 下的所有脚本
   - 包括 Bash 和 PowerShell 脚本

---

## 🚀 使用方法

### 新项目（自动配置）

运行 `socrate init` 时会自动创建配置：

```bash
socrate init my-learning-project
cd my-learning-project
code .
```

✅ `.vscode/settings.json` 已自动创建！

### 已有项目（更新配置）

对于已存在的 Socrate 项目：

```bash
socrate update
```

✅ 会自动合并配置到现有 `settings.json`（不会覆盖其他设置）

---

## 🔒 安全说明

### 哪些命令被自动审批？

- ✅ **安全脚本**: `.specify/scripts/` 目录下的所有教学脚本
- ✅ **只读 Git 命令**: `git status`, `git diff`, `git log` 等
- ✅ **查看命令**: `ls`, `cat`, `pwd`, `Get-Content` 等

### 哪些命令仍需手动确认？

- ❌ **危险命令**: `rm`, `del`, `Remove-Item`, `kill`
- ❌ **修改 Git**: `git push`, `git reset`, `git revert`
- ❌ **包管理**: `npm install`, `pip install`

### 完全 YOLO 模式（不推荐）

如果你想自动审批**所有**命令（仅在沙盒环境），可在 `settings.json` 添加：

```json
{
    "chat.tools.autoApprove": true
}
```

⚠️ **警告**: 这会移除所有安全检查！

---

## 📚 参考资料

- [VS Code Copilot Settings 官方文档](https://code.visualstudio.com/docs/copilot/reference/copilot-settings)
- [GitHub Issue #252496: Auto-approve terminal commands](https://github.com/microsoft/vscode/issues/252496)
- [YOLO Mode Configuration Guide](https://gist.github.com/intellectronica/c4fc19f31ac38d7d251f0dc6af8ab661)

---

## 🛠️ 手动配置

如果你想手动编辑配置：

1. 打开项目根目录
2. 创建/编辑 `.vscode/settings.json`
3. 添加上面的 JSON 配置
4. 重启 VS Code（可选）

---

## ❓ 常见问题

**Q: 配置后还是需要手动确认？**  
A: 确保：
- VS Code 版本 >= 1.95
- GitHub Copilot 扩展已更新到最新版本
- `.vscode/settings.json` 格式正确（无语法错误）

**Q: 我想禁用某个脚本的自动审批？**  
A: 在 `settings.json` 中添加：
```json
{
    "chat.tools.terminal.autoApprove": {
        "/Update-Progress\\.ps1/": false
    }
}
```

**Q: 配置会影响其他项目吗？**  
A: 不会！`.vscode/settings.json` 是项目级配置，只影响当前 Socrate 项目。

---

**版本**: Socrate 0.2.0+  
**最后更新**: 2025-10-29
