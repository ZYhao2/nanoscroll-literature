# 纳米卷 (Nanoscroll) 文献数据库

> 自动收集、整理和监控纳米卷相关学术文献

## 📖 什么是纳米卷？

**纳米卷 (Nanoscroll)** 是一种由二维材料（如石墨烯、MoS₂、BN等）卷曲而成的螺旋/卷轴状纳米结构。与碳纳米管不同，纳米卷具有开放的端部和可调层间距，展现出独特的电子、光学和力学性质。

## 📂 仓库结构

```
nanoscroll-literature/
├── README.md                 # 本文件
├── papers/
│   ├── index.md              # 所有文献的主索引（含影响因子）
│   ├── papers.json           # 完整机器可读数据库
│   └── by-year/              # 按年份分类的文献
│       ├── 2026.md
│       ├── 2025.md
│       ├── 2024.md
│       └── ...
├── impact-factors.md         # 期刊影响因子表
└── scripts/
    ├── daily-check.sh        # 日常文献检查脚本
    └── search-arxiv.sh       # arXiv 搜索脚本
```

## 🔄 自动更新

本仓库通过 Hermes Agent 的 cron 任务**每日自动更新**新文献。

## 📊 影响因子可信度

所有文献均标注了发表期刊的影响因子 (IF)，帮助判断可信度：
- **IF ≥ 10**：顶级期刊，非常可信
- **IF 5-10**：高水平期刊，可信
- **IF 2-5**：标准期刊，可信度中等
- **IF < 2**：一般期刊或预印本（arXiv），需谨慎参考

## 🤝 维护者

- 自动维护：Hermes Agent (Nous Research)
- GitHub: [@ZYhao2](https://github.com/ZYhao2)
