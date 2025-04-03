#!/usr/bin/env bash

#----------------------- installing client --------------------
copy_client() {
  target="$1"
  echo "Copying client files to $target"

  mkdir "$target"
  mkdir "$target/data"
  mkdir "$target/data/logs"
  mkdir "$target/data/config"

  cp -r client/* "$target"
  cp silver "${target}/pc-print-client-service"
  chmod +x "${target}/pc-print-client-service"
  cp updater "${target}/pc-print-client-updater"
  chmod +x "${target}/pc-print-client-updater"
}

install_queue() {
  target="$1"
  echo "Installing PaperCut Printer"
  PRINTER_ID="PAPERCUT_POCKET_PRINTER"
  PRINTER_NAME="PaperCut Printer"

  "${target}/pc-print-client-service" command install-queue -printerId="PAPERCUT_POCKET_PRINTER" -printerName="PaperCut Printer"
}

install_client_service() {
  target="$1"
  echo "Installing print client service"
  "${target}/pc-print-client-service" install

  "${target}/pc-print-client-service" start
}

bulk_link_client() {
  local region="$1"
  local orgId="$2"
  echo "bulk link command params: -region=$region -region=$orgId"
 "${target}/pc-print-client-service" command bulk-link --region "${region}" --orgId "${orgId}"
}

install_client() {
  target="$HOME/Library/PaperCut Hive"
  local region="$1"
  local orgId="$2"
  copy_client "${target}"
  install_queue "${target}"
  bulk_link_client "${region}" "${orgId}"
  install_client_service "${target}"
}

# ----------------------- installing edgenode ---------------------------------
copy_en() {
  target="$1"
  echo "Copying edgenode files to $target"

  mkdir "$target"
  mkdir "$target/data"
  mkdir "$target/data/logs"
  mkdir "$target/data/config"

  cp -r edgenode/* "$target"
  cp silver "${target}/pc-edgenode-service"
  chmod +x "${target}/pc-edgenode-service"
  cp updater "${target}/pc-edgenode-updater"
  chmod +x "${target}/pc-edgenode-updater"

  "${target}/pc-edgenode-service" command split-edgenode
}

link_en() {
  target="$1"
  system_key="$2"
  local region="$3"
  echo "linking edgenode"
  "${target}/pc-edgenode-service" command link --bulklink --region "$region" --systemKey "$system_key" --appVersion="2025-02-25-0415" --edgenodeUpdaterPath="./pc-edgenode-updater"
}

install_en_service() {
  target="$1"
  echo "Installing edgenode service"
  "${target}/pc-edgenode-service" install
  echo "installing DPM"
  "${app_home}/pc-edgenode-service" command install-dpm
  echo "Starting edgenode service"
  "${target}/pc-edgenode-service" start
}

install_en() {
  system_key=$1
  local region=$2
  target="/Library/PaperCut Hive"
  copy_en "${target}"
  link_en "${target}" "${system_key}" "${region}"
  install_en_service "${target}"
}

update_user_in_uninstall() {
  user_name=$1
  uninstall_file="/Library/PaperCut Hive/Uninstall.command"
  cat Uninstall.command \
      | sed "s|@user_name@|"${user_name}"|g" \
      > "${uninstall_file}"
  chmod +x "${uninstall_file}"
}

# -----------------------------------------------------------------
echo "running installer script with args: $1 $2 $3"
region=$2
orgId=$3
if [[ "$1" == "install_client" ]]; then
  echo "running install_client as $(whoami)"
  install_client "${region}" "${orgId}"
else
  system_key=$1
  echo "running install_en as $(whoami)"
  install_en "${system_key}" "${region}"  ç
  current_user=$(stat -f%Su /dev/console )
  echo change ownership of current dir to ${current_user}
  chown -R ${current_user} .
  current_dir=$PWD
  su - ${current_user} -c "(cd $current_dir && $0 install_client ${region} ${orgId})"

  echo "updating uninstall script"
  update_user_in_uninstall $current_user
fi
