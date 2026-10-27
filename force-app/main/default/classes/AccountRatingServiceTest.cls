/**
 * AccountRatingService のテスト。
 * 境界値と、200件の一括処理でガバナ制限に引っかからないことを確認する。
 */
@IsTest
private class AccountRatingServiceTest {

    @IsTest
    static void ratingForReturnsExpectedValuesAtBoundaries() {
        Assert.areEqual('Cold', AccountRatingService.ratingFor(null), '売上が未入力なら Cold');
        Assert.areEqual('Cold', AccountRatingService.ratingFor(AccountRatingService.WARM_THRESHOLD - 1), '閾値未満は Cold');
        Assert.areEqual('Warm', AccountRatingService.ratingFor(AccountRatingService.WARM_THRESHOLD), '1千万円ちょうどは Warm');
        Assert.areEqual('Hot', AccountRatingService.ratingFor(AccountRatingService.HOT_THRESHOLD), '1億円ちょうどは Hot');
    }

    @IsTest
    static void recalculateUpdatesTwoHundredAccountsInBulk() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 200; i++) {
            accounts.add(new Account(
                Name = 'テスト取引先 ' + i,
                AnnualRevenue = Math.mod(i, 2) == 0 ? AccountRatingService.HOT_THRESHOLD : 0
            ));
        }
        insert accounts;

        Set<Id> ids = new Map<Id, Account>(accounts).keySet();

        Test.startTest();
        AccountRatingService.recalculate(ids);
        Integer queriesUsed = Limits.getQueries();
        Test.stopTest();

        Assert.isTrue(queriesUsed <= 1, '200件でもSOQLは1回だけのはず: ' + queriesUsed);

        Integer hotCount = 0;
        Integer coldCount = 0;
        for (Account acc : [SELECT Rating FROM Account WHERE Id IN :ids]) {
            if (acc.Rating == 'Hot') {
                hotCount++;
            } else if (acc.Rating == 'Cold') {
                coldCount++;
            }
        }
        Assert.areEqual(100, hotCount, '偶数番目の100件は Hot');
        Assert.areEqual(100, coldCount, '奇数番目の100件は Cold');
    }

    @IsTest
    static void emptyInputDoesNothing() {
        Test.startTest();
        AccountRatingService.applyRatings(new List<Account>());
        AccountRatingService.recalculate(new Set<Id>());
        Test.stopTest();

        Assert.areEqual(0, Limits.getQueries(), '空の入力ではSOQLを実行しない');
    }
}
