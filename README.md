# ansibleクライアント

## 特徴

 - ansible-playbookのラッパー
 - バージョンを固定してインストール。
 - このリポジトリがアップデートされるたびに、変更に追従してansibleも自動でアップデート。

## 使い方（例）

好みに応じて、どうぞ。

### ラッパーを使う

```bash
# MangaHoge_ansibleの直下で

git submodule init
git submodule add git@github.com:link-u/ansible-tools_client.git client

client/ansible-playbook -i hosts .....
client/ansible -m ping ....
```

### activateを使う

```bash
# MangaHoge_ansibleの直下で

git submodule init
git submodule add git@github.com:link-u/ansible-tools_client.git client

. client/_scripts/activate

ansible-playbook -i hosts ...
ansible -m ping ...

# すべてが終わったら
deactivate
```

zsh向けに次みたいなヘルパも作りました、.zshrcにでも放り込んでみてね。

```zsh
function use-ansible() {
  local root=$(git rev-parse --show-toplevel)
  if [ ! -d ${root} ]; then
    echo "You are not on any git repository."
    return -1
  fi
  local repo=$(echo $(basename ${root}) | sed -e 's/_/\//')
  zsh --login -c "\
    source ${root}/client/_scripts/activate &&\
    RPROMPT='%B%K{239}%F{212}[${repo}]%f%k%b %B%(?.%{%F{blue}%}.%{%F{red}%})%D %{%F{red}%}%T%b' zsh"
}
```

これをセットすると、各プロジェクトごとのansibleがactivateされます（その旨の表示も出るよ）。

![use-ansible.png](use-ansible.png)

## パッケージを追加したい

デフォルトだと `_scripts` 以下の `req.txt` にあるライブラリのみインストールするが、プロジェクトによっては他のライブラリもインストールしたいケースがある。  
その場合、プロジェクトのリポジトリルートに `req.txt` を置いてそれに追記する。

### ディレクトリ構造

```
ansible-project/
├── hosts       # インベントリファイル
├── client/...  # ansible-tools_client
├── req.txt     # これを作成
├── roles/
```

### 追加するreq.txtの中身の例

以下はpasslibを追加している。

```
ansible>=2.10,<2.11
Jinja2>=2.11,<2.12
passlib==1.7.4
```

## その他

[_scripts/req.txt](_scripts/req.txt)が更新されるたびに_venvs/が肥大化していくので、たまに消してあげてください。
