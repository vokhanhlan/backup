# csv import関連javascript

$ ->
  # inputされたCSVファイルをtableでpreview表示
  csvInput = $('#csvInput')
  if csvInput.size() > 0
    csvInput.on('change', (event) ->
      csv_file = event.target.files[0]
      reader = new FileReader()
      reader.onload = (file) ->
        csv_data = file.target.result
        # "\r"を削除し、Windowsの改行コード(\r\n)をmacの改行コード(\n)に変換
        tmp_data = csv_data.replace(/\r/g,'')
        # 各行末の","を削除
        tmp_data = tmp_data.replace(/,\n/g,"\n").replace(/,$/,'')
        # tableデータ生成
        table_data = "<table><tr><td>"
        i = 0
        while tmp_data != ""
          # 無限ループ防止 15列*9999件(150,000)まで表示
          if i >= 150000
            alert("プレビューの最大表示件数を超えました。プレビューは999件まで表示できます。")
            break
          else
            i++
          # csv -> table
          if tmp_data[0] == ","
            # 該当セルが空欄の場合
            table_data += "</td><td>"
            tmp_data = tmp_data.replace(/^,/, "")
          else if tmp_data[0] == "\""
            # 該当セルが改行,コンマを含むデータ(ダブルクォーテーション区切り)の場合
            table_data += tmp_data.match(/^"[\s\S]+?[^"]"[,\n]/)
            # 最終列("any word"\n)だった場合は<tr>を付与する
            if table_data.lastIndexOf("\n") == (table_data.length - 1)
              table_data += "</td></tr><tr><td>"
            else
              table_data += "</td><td>"
            tmp_data = tmp_data.replace(/^"[\s\S]+?[^"]"[,\n]/, "")
          else
            # 上記以外の任意の文字列から始まる場合
            indexOfComma = tmp_data.indexOf(",")
            indexOfCR = tmp_data.indexOf("\n")
            if indexOfComma == -1
              # 最終行最終列の場合
              table_data += tmp_data
              tmp_data = tmp_data.replace(/^[\s\S]+$/, "")
            else if indexOfCR == -1 || indexOfComma < indexOfCR
              # 最終列以前(,区切り)の場合
              table_data += tmp_data.slice(0, indexOfComma)
              table_data += "</td><td>"
              tmp_data = tmp_data.replace(/^.+?,/, "")
            else
              # 最終列(\n区切り)の場合
              table_data += tmp_data.slice(0, indexOfCR)
              table_data += "</td></tr><tr><td>"
              tmp_data = tmp_data.replace(/^.+?\n/, "")
        # 最終データの不要な閉じタグを削除
        table_data = table_data.replace(/<tr><td>$/, "")
        table_data = table_data.replace(/<\/td><td>$/, "")
        table_data = table_data.replace(/<\/td><\/tr>$/, "")
        table_data += "</td></tr></table>"
        $('#csvPreview').html(table_data)

      reader.readAsText(csv_file)
      # 表示エリアの切替
      $('#descriptionArea').hide()
      $('#previewArea').show()
      return false
    )
