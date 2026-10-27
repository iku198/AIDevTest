/**
 * 取引先の年間売上から評価（Rating）を決めるサンプルクラス。
 * coding-rules の書き方の見本：一括処理前提、ループ内でSOQL/DMLを書かない、with sharing。
 */
public with sharing class AccountRatingService {

    @TestVisible
    private static final Decimal HOT_THRESHOLD = 100000000;  // 1億円以上は Hot
    @TestVisible
    private static final Decimal WARM_THRESHOLD = 10000000;  // 1千万円以上は Warm

    /**
     * 渡された取引先の Rating を年間売上から決めて設定する（保存はしない）。
     * トリガーから呼ぶ想定なので、200件まとめて渡されても問題ないように書く。
     */
    public static void applyRatings(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()) {
            return;
        }
        for (Account acc : accounts) {
            acc.Rating = ratingFor(acc.AnnualRevenue);
        }
    }

    /**
     * 指定した取引先IDの Rating を再計算して保存する。
     * SOQLとDMLはループの外で1回ずつだけ実行する。
     */
    public static void recalculate(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }
        List<Account> accounts = [
            SELECT Id, AnnualRevenue, Rating
            FROM Account
            WHERE Id IN :accountIds
            WITH USER_MODE
        ];
        applyRatings(accounts);
        Database.update(accounts, AccessLevel.USER_MODE);
    }

    @TestVisible
    private static String ratingFor(Decimal annualRevenue) {
        if (annualRevenue == null) {
            return 'Cold';
        }
        if (annualRevenue >= HOT_THRESHOLD) {
            return 'Hot';
        }
        if (annualRevenue >= WARM_THRESHOLD) {
            return 'Warm';
        }
        return 'Cold';
    }
}
