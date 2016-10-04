EXECUTE msdb.dbo.sp_add_alert @name = N'SA non-trusted login',
@message_id = 18454, @severity = 0, @enabled = 1,
@delay_between_responses = 8, @include_event_description_in = 5,
@event_description_keyword = N'''sa''', @job_name = N'SA login email notify',@category_name = N'[Uncategorized]'
