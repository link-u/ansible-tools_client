# ansibleクライアント

## 特徴

 - ansible-playbookのラッパー
 - バージョンを固定してインストール。
 - このリポジトリがアップデートされるたびに、変更に追従してansibleも自動でアップデート。

## 使い方（例）

```bash
./ansible-playbook -i hosts .....
./ansible -m ping ....
```

このフォルダをPATHに追加しても動くように書かれています。

## その他

[_scripts/req.txt](_scripts/req.txt)が更新されるたびに_venvs/が肥大化していくので、たまに消してあげてください。
