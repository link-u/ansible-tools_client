# ansibleクライアント

## 特徴

 - ansible-playbookのラッパー
 - バージョンを固定してインストール。
 - このリポジトリがアップデートされるたびに、変更に追従してansibleも自動でアップデート。

## 使い方（例）

好みに応じて、どうぞ。

### ラッパーを使う

```bash
git submodule init
git submodule add git@github.com:link-u/ansible-tools_client.git client

client/ansible-playbook -i hosts .....
client/ansible -m ping ....
```

### activateを使う

```bash
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

これをセットすると、各プロジェクトごとのansibleが有効になります（その旨の表示も出るよ）。

![use-ansible.png](use-ansible.png)

## その他

[_scripts/req.txt](_scripts/req.txt)が更新されるたびに_venvs/が肥大化していくので、たまに消してあげてください。
