Ceph備忘
-----------------

Ceph客戶端在讀取和寫數據前，要先從Ceph Monitor獲取最近的cluster map,爲了防止Ceph Monitor成爲單點，通常Ceph Monitor是一個集羣。因爲有多個Monitor,每個Monitor手裏的cluster map的值可能不一樣，可能會產生`拜占庭失敗`,Ceph採用了著名的`Paxos`來解決這個問題。
































* http://cephnotes.ksperis.com/
